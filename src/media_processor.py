"""
Media processor for intelligent image/video resizing and cropping.
Analyzes aspect ratios and selects best-fit media for each poster size.
"""
import os
from pathlib import Path
from typing import Tuple, Optional, List, Dict
import math
from PIL import Image
import cv2


# Target poster dimensions (width, height)
POSTER_SPECS = {
    "Poster1": (639, 488),
    "Poster2": (730, 490),
    "Poster3": (749, 1054),
    "Poster4": (729, 999),
    "Poster5": (552, 769),
    "CustomTips": (860, 1219),
}

SUPPORTED_IMAGE_FORMATS = {".png", ".jpg", ".jpeg", ".bmp"}
SUPPORTED_VIDEO_FORMATS = {".mp4"}


class MediaInfo:
    """Store media file info and aspect ratio analysis."""
    
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.extension = Path(file_path).suffix.lower()
        self.is_video = self.extension in SUPPORTED_VIDEO_FORMATS
        self.is_image = self.extension in SUPPORTED_IMAGE_FORMATS
        self.width = 0
        self.height = 0
        self.aspect_ratio = 0.0
        
        if self.is_image:
            self._analyze_image()
        elif self.is_video:
            self._analyze_video()
    
    def _analyze_image(self):
        """Extract dimensions from image file."""
        try:
            img = Image.open(self.file_path)
            self.width, self.height = img.size
            self.aspect_ratio = self.width / self.height if self.height > 0 else 0
        except Exception as e:
            print(f"Error analyzing image {self.file_path}: {e}")
    
    def _analyze_video(self):
        """Extract dimensions from video file using OpenCV."""
        try:
            cap = cv2.VideoCapture(self.file_path)
            self.width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            self.height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            self.aspect_ratio = self.width / self.height if self.height > 0 else 0
            cap.release()
        except Exception as e:
            print(f"Error analyzing video {self.file_path}: {e}")


class MediaProcessor:
    """Process media: select best fit, crop, and resize for each poster."""
    
    def __init__(self, input_dir: str, tolerance_percent: float = 5.0):
        self.input_dir = Path(input_dir)
        self.tolerance_percent = tolerance_percent
        self.media_list: List[MediaInfo] = []
        self.used_media: set = set()
    
    def discover_media(self) -> List[MediaInfo]:
        """Find all supported media files in input directory."""
        self.media_list = []
        
        for file_path in self.input_dir.rglob("*"):
            if file_path.is_file():
                ext = file_path.suffix.lower()
                if ext in SUPPORTED_IMAGE_FORMATS or ext in SUPPORTED_VIDEO_FORMATS:
                    media = MediaInfo(str(file_path))
                    if media.width > 0 and media.height > 0:
                        self.media_list.append(media)
        
        return self.media_list
    
    def calculate_aspect_ratio_fit(self, media_aspect: float, target_aspect: float) -> float:
        """
        Calculate fit score (0-1, higher is better).
        Score is based on how close the media aspect ratio is to target.
        """
        if media_aspect <= 0 or target_aspect <= 0:
            return 0.0
        
        ratio = media_aspect / target_aspect
        # Penalize ratios outside tolerance
        if ratio < (1 - self.tolerance_percent / 100) or ratio > (1 + self.tolerance_percent / 100):
            tolerance_penalty = 0.5  # Give some credit even if outside tolerance
            return tolerance_penalty * (1 - abs(1 - ratio) * 0.5)
        
        # Within tolerance: score based on how close to perfect match
        return 1.0 - abs(1 - ratio) * 0.1
    
    def select_best_media_for_poster(
        self,
        poster_name: str,
        prefer_video: bool = False,
        require_video: bool = False,
        exclude_used: bool = True,
    ) -> Optional[MediaInfo]:
        """
        Select the best media file for a given poster size.
        
        Args:
            poster_name: Name of poster (e.g., "Poster1", "CustomTips")
            prefer_video: If True, prefer video over image (but still match aspect ratio)
            require_video: If True, ONLY return a video (first available, regardless of fit)
            exclude_used: If True, skip media already assigned to another poster
        
        Returns:
            Best matching MediaInfo or None if no suitable media found
        """
        target_width, target_height = POSTER_SPECS[poster_name]
        target_aspect = target_width / target_height
        
        # If require_video, return first available video regardless of aspect ratio fit
        if require_video:
            for media in self.media_list:
                if media.is_video and (not exclude_used or media.file_path not in self.used_media):
                    return media
            return None  # No video found
        
        best_media = None
        best_score = -1
        
        for media in self.media_list:
            if exclude_used and media.file_path in self.used_media:
                continue
            
            fit_score = self.calculate_aspect_ratio_fit(media.aspect_ratio, target_aspect)
            
            # Apply video preference (strong boost if prefer_video)
            if prefer_video and media.is_video:
                fit_score = max(fit_score, 0.7)  # Boost video score even if aspect ratio is off
                fit_score *= 2.0
            elif prefer_video and media.is_image:
                fit_score *= 0.8
            
            if fit_score > best_score:
                best_score = fit_score
                best_media = media
        
        return best_media
    
    def crop_and_resize(
        self,
        media: MediaInfo,
        target_width: int,
        target_height: int,
        output_path: str,
    ) -> bool:
        """
        Crop media to match target aspect ratio, then resize.
        Uses crop-first strategy to avoid letterboxing.
        
        Args:
            media: MediaInfo object
            target_width: Target width in pixels
            target_height: Target height in pixels
            output_path: Where to save the processed file
        
        Returns:
            True if successful, False otherwise
        """
        try:
            if media.is_image:
                return self._crop_resize_image(
                    media.file_path, target_width, target_height, output_path
                )
            elif media.is_video:
                return self._crop_resize_video(
                    media.file_path, target_width, target_height, output_path
                )
        except Exception as e:
            print(f"Error processing {media.file_path}: {e}")
            return False
        
        return False
    
    def _crop_resize_image(
        self, input_path: str, target_width: int, target_height: int, output_path: str
    ) -> bool:
        """Crop and resize image using PIL."""
        img = Image.open(input_path)
        src_width, src_height = img.size
        target_aspect = target_width / target_height
        src_aspect = src_width / src_height
        
        # Calculate crop box to match target aspect ratio
        if src_aspect > target_aspect:
            # Image is wider: crop width
            new_width = int(src_height * target_aspect)
            left = (src_width - new_width) // 2
            crop_box = (left, 0, left + new_width, src_height)
        else:
            # Image is taller: crop height
            new_height = int(src_width / target_aspect)
            top = (src_height - new_height) // 2
            crop_box = (0, top, src_width, top + new_height)
        
        # Crop then resize
        cropped = img.crop(crop_box)
        resized = cropped.resize((target_width, target_height), Image.Resampling.LANCZOS)
        
        # Determine output format
        if output_path.lower().endswith(".png"):
            resized.save(output_path, "PNG")
        elif output_path.lower().endswith((".jpg", ".jpeg")):
            resized.save(output_path, "JPEG", quality=95)
        else:
            resized.save(output_path)
        
        return True
    
    def _crop_resize_video(
        self, input_path: str, target_width: int, target_height: int, output_path: str
    ) -> bool:
        """Crop and resize video using OpenCV and FFmpeg."""
        # Read first frame to get dimensions
        cap = cv2.VideoCapture(input_path)
        src_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        src_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        cap.release()
        
        target_aspect = target_width / target_height
        src_aspect = src_width / src_height
        
        # Calculate crop dimensions
        if src_aspect > target_aspect:
            crop_width = int(src_height * target_aspect)
            crop_height = src_height
            crop_x = (src_width - crop_width) // 2
            crop_y = 0
        else:
            crop_width = src_width
            crop_height = int(src_width / target_aspect)
            crop_x = 0
            crop_y = (src_height - crop_height) // 2
        
        # Use FFmpeg to crop and resize (more efficient than OpenCV)
        import subprocess
        
        ffmpeg_cmd = [
            "ffmpeg",
            "-i", input_path,
            "-vf", f"crop={crop_width}:{crop_height}:{crop_x}:{crop_y},scale={target_width}:{target_height}",
            "-c:v", "libx264",
            "-preset", "fast",
            "-crf", "23",
            "-c:a", "aac",
            "-y",
            output_path,
        ]
        
        try:
            subprocess.run(ffmpeg_cmd, check=True, capture_output=True)
            return True
        except subprocess.CalledProcessError as e:
            print(f"FFmpeg error: {e.stderr.decode()}")
            return False
    
    def process_media_set(
        self, media_set: List[MediaInfo], output_dir: str
    ) -> Dict[str, str]:
        """
        Process a set of media files and assign to poster positions.
        
        Args:
            media_set: List of media files to process (should be 6 items)
            output_dir: Directory to save processed files
        
        Returns:
            Dict mapping poster name to output file path
        """
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        result = {}
        
        # Mark these media as used
        for media in media_set:
            self.used_media.add(media.file_path)
        
        # Assign one video if possible, rest images
        video_assigned = False
        poster_order = ["Poster1", "Poster2", "Poster3", "Poster4", "Poster5", "CustomTips"]
        
        for idx, poster_name in enumerate(poster_order):
            if idx < len(media_set):
                media = media_set[idx]
                target_width, target_height = POSTER_SPECS[poster_name]
                
                # Determine output format
                if media.is_video:
                    output_file = f"{poster_name}.mp4"
                else:
                    output_file = f"{poster_name}.png"
                
                output_path = os.path.join(output_dir, output_file)
                
                if self.crop_and_resize(media, target_width, target_height, output_path):
                    result[poster_name] = output_path
                    print(f"✓ {poster_name} -> {output_file}")
                else:
                    print(f"✗ Failed to process {poster_name}")
        
        return result
