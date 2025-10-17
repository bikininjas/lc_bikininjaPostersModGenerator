"""
Mod generator: Creates BepInEx directory structure and packages mods.
Tracks version and ensures media uniqueness across mods.
"""
import os
import json
import zipfile
from pathlib import Path
from typing import Dict, List, Optional


class ModConfig:
    """Configuration for a single mod pack."""
    
    def __init__(self, mod_number: int, version: str = "0.0.1"):
        self.mod_number = mod_number
        self.version = version
        self.mod_name = f"BikininjaPosters{mod_number:02d}"
        self.mod_dir_name = f"BikininjasPosters{mod_number:02d}"
        self.media_files = {}  # poster_name -> file_path
    
    def get_mod_structure_root(self, base_dir: str) -> str:
        """Return the root BepInEx path for this mod."""
        return os.path.join(base_dir, self.mod_name, "BepInEx", "plugins", self.mod_dir_name)
    
    def get_custom_posters_dir(self, base_dir: str) -> str:
        """Return CustomPosters directory path."""
        return os.path.join(self.get_mod_structure_root(base_dir), "CustomPosters")
    
    def to_dict(self) -> dict:
        """Serialize config to dict for tracking."""
        return {
            "mod_number": self.mod_number,
            "version": self.version,
            "mod_name": self.mod_name,
            "media_files": self.media_files,
        }


class VersionTracker:
    """Track and manage versions for each mod independently."""
    
    def __init__(self, tracking_file: str = "mods/versions.json"):
        self.tracking_file = tracking_file
        self.versions = {}
        self.used_media = set()  # Track which source files have been used
        self.load()
    
    def load(self):
        """Load version tracking from file."""
        if os.path.exists(self.tracking_file):
            try:
                with open(self.tracking_file, "r") as f:
                    data = json.load(f)
                    # Handle both old format (just versions) and new format (versions + used_media)
                    if isinstance(data, dict):
                        if "versions" in data:
                            self.versions = data["versions"]
                            self.used_media = set(data.get("used_media", []))
                        else:
                            # Old format: assume all keys are version strings
                            self.versions = data
            except Exception as e:
                print(f"Error loading version file: {e}")
                self.versions = {}
                self.used_media = set()
    
    def save(self):
        """Save version tracking to file."""
        Path(self.tracking_file).parent.mkdir(parents=True, exist_ok=True)
        data = {
            "versions": self.versions,
            "used_media": sorted(list(self.used_media))
        }
        with open(self.tracking_file, "w") as f:
            json.dump(data, f, indent=2)
    
    def mark_media_used(self, file_path: str):
        """Mark a source media file as used."""
        self.used_media.add(file_path)
    
    def is_media_used(self, file_path: str) -> bool:
        """Check if a source media file has been used."""
        return file_path in self.used_media
    
    def get_next_version(self, mod_number: int) -> str:
        """Get next version for a mod (e.g., 0.0.1, 0.0.2, ...)."""
        mod_key = f"BikininjaPosters{mod_number:02d}"
        
        if mod_key not in self.versions:
            self.versions[mod_key] = "0.0.0"
        
        current = self.versions[mod_key]
        parts = list(map(int, current.split(".")))
        parts[2] += 1  # Increment patch version
        
        next_version = ".".join(map(str, parts))
        self.versions[mod_key] = next_version
        return next_version
    
    def increment_version_for_mod(self, mod_number: int) -> str:
        """Increment and return new version."""
        next_ver = self.get_next_version(mod_number)
        self.save()
        return next_ver


class ModGenerator:
    """Generate mod directory structures and package them."""
    
    def __init__(self, output_dir: str = "mods"):
        self.output_dir = output_dir
        self.version_tracker = VersionTracker(os.path.join(output_dir, "versions.json"))
        self.used_media = set()  # Track all media used across all mods
    
    def create_mod_structure(self, mod_config: ModConfig, media_files: Dict[str, str]) -> bool:
        """
        Create BepInEx directory structure for a mod.
        
        Args:
            mod_config: ModConfig object
            media_files: Dict mapping poster_name to file path
        
        Returns:
            True if successful
        """
        try:
            # Create directories
            custom_posters_dir = mod_config.get_custom_posters_dir(self.output_dir)
            posters_dir = os.path.join(custom_posters_dir, "posters")
            tips_dir = os.path.join(custom_posters_dir, "tips")
            
            Path(posters_dir).mkdir(parents=True, exist_ok=True)
            Path(tips_dir).mkdir(parents=True, exist_ok=True)
            
            # Copy media files to correct locations
            for poster_name, file_path in media_files.items():
                if poster_name == "CustomTips":
                    dest_dir = tips_dir
                    dest_name = "CustomTips" + Path(file_path).suffix
                else:
                    dest_dir = posters_dir
                    dest_name = poster_name + Path(file_path).suffix
                
                dest_path = os.path.join(dest_dir, dest_name)
                
                # Copy file
                import shutil
                shutil.copy2(file_path, dest_path)
                
                # Track used media
                self.used_media.add(file_path)
                mod_config.media_files[poster_name] = dest_name
            
            print(f"✓ Created mod structure: {mod_config.mod_name}")
            return True
        
        except Exception as e:
            print(f"✗ Error creating mod structure: {e}")
            return False
    
    def create_mod_archive(
        self, mod_config: ModConfig, archive_output_dir: str = "build"
    ) -> Optional[str]:
        """
        Create a zip archive of the mod in Thunderstore format.
        
        Args:
            mod_config: ModConfig object
            archive_output_dir: Directory to save zip file
        
        Returns:
            Path to created zip file, or None if failed
        """
        try:
            Path(archive_output_dir).mkdir(parents=True, exist_ok=True)
            
            mod_root = os.path.join(self.output_dir, mod_config.mod_name)
            archive_name = f"{mod_config.mod_name}-v{mod_config.version}.zip"
            archive_path = os.path.join(archive_output_dir, archive_name)
            
            with zipfile.ZipFile(archive_path, "w", zipfile.ZIP_DEFLATED) as zipf:
                for root, dirs, files in os.walk(mod_root):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, mod_root)
                        zipf.write(file_path, arcname)
            
            print(f"✓ Created archive: {archive_name}")
            return archive_path
        
        except Exception as e:
            print(f"✗ Error creating archive: {e}")
            return None
    
    def get_next_mod_number(self) -> int:
        """Get next available mod number."""
        existing_mods = []
        
        if os.path.exists(self.output_dir):
            for item in os.listdir(self.output_dir):
                if item.startswith("BikininjaPosters") and item != "versions.json":
                    try:
                        num = int(item.replace("BikininjaPosters", ""))
                        existing_mods.append(num)
                    except ValueError:
                        pass
        
        return max(existing_mods) + 1 if existing_mods else 1
    
    def get_media_used_by_mods(self) -> set:
        """Return set of all media files already used in mods."""
        return self.used_media.copy()
    
    def load_existing_usage(self):
        """Load usage info from existing mods to populate used_media."""
        if not os.path.exists(self.output_dir):
            return
        
        for item in os.listdir(self.output_dir):
            mod_path = os.path.join(self.output_dir, item)
            if os.path.isdir(mod_path) and item.startswith("BikininjaPosters"):
                # Walk through and collect media file paths
                for root, dirs, files in os.walk(mod_path):
                    for file in files:
                        if file.lower().endswith((".png", ".mp4", ".jpg", ".jpeg", ".bmp")):
                            self.used_media.add(os.path.join(root, file))
