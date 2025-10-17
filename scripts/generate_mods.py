#!/usr/bin/env python3
"""
Main CLI entry point for generating BikininjaPosters mods.

Usage:
    python scripts/generate_mods.py --input ./input --output ./mods --build ./build

Environment:
    POSTER_INPUT_DIR: Override input directory
    POSTER_OUTPUT_DIR: Override output directory
    POSTER_BUILD_DIR: Override build directory
"""
import sys
import os
import argparse
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from media_processor import MediaProcessor, POSTER_SPECS
from mod_generator import ModGenerator, ModConfig


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate Thunderstore CustomPosters mods from media files"
    )
    parser.add_argument(
        "--input",
        default=os.getenv("POSTER_INPUT_DIR", "./input"),
        help="Input directory containing source media files",
    )
    parser.add_argument(
        "--output",
        default=os.getenv("POSTER_OUTPUT_DIR", "./mods"),
        help="Output directory for generated mods",
    )
    parser.add_argument(
        "--build",
        default=os.getenv("POSTER_BUILD_DIR", "./build"),
        help="Build directory for zip archives",
    )
    parser.add_argument(
        "--tolerance",
        type=float,
        default=5.0,
        help="Aspect ratio tolerance in percent (default: 5)",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    
    print("=" * 60)
    print("BikininjaPosters Mod Generator")
    print("=" * 60)
    print(f"Input directory:  {args.input}")
    print(f"Output directory: {args.output}")
    print(f"Build directory:  {args.build}")
    print()
    
    # Step 1: Discover media
    print("[1/4] Discovering media files...")
    processor = MediaProcessor(args.input, tolerance_percent=args.tolerance)
    media_list = processor.discover_media()
    print(f"Found {len(media_list)} media files")
    
    if not media_list:
        print("✗ No media files found. Exiting.")
        return 1
    
    # Print summary
    video_count = sum(1 for m in media_list if m.is_video)
    image_count = sum(1 for m in media_list if m.is_image)
    print(f"  - Videos: {video_count}")
    print(f"  - Images: {image_count}")
    print()
    
    # Step 2: Load existing usage
    print("[2/4] Loading existing mod data...")
    mod_gen = ModGenerator(args.output)
    mod_gen.load_existing_usage()
    used_media = mod_gen.get_media_used_by_mods()
    
    # Also add media from version tracker
    for media_path in mod_gen.version_tracker.used_media:
        used_media.add(media_path)
        processor.used_media.add(media_path)
    
    print(f"Already used: {len(used_media)} media files")
    print()
    
    # Step 3: Assign media to new mods
    print("[3/4] Assigning media to posters and creating mods...")
    num_new_mods = len(media_list) // 6
    
    if num_new_mods == 0:
        print("✗ Not enough media to create a mod (need 6, have {})".format(len(media_list)))
        return 1
    
    print(f"Will create {num_new_mods} new mod(s)")
    print()
    
    created_mods = []
    poster_names = list(POSTER_SPECS.keys())
    
    for mod_idx in range(num_new_mods):
        mod_number = mod_gen.get_next_mod_number()
        next_version = mod_gen.version_tracker.get_next_version(mod_number)
        
        mod_config = ModConfig(mod_number, next_version)
        print(f"Creating {mod_config.mod_name} (v{next_version})...")
        
        # Intelligently select media for this mod using smart aspect ratio matching
        media_dict = {}
        has_video = False
        selected_videos = []
        
        # First pass: find all available videos (preferred but not required for testing)
        for media in processor.media_list:
            if media.is_video and media.file_path not in processor.used_media:
                selected_videos.append(media)
        
        # Select media for all 6 poster positions
        video_selected = False
        for poster_idx, poster_name in enumerate(poster_names):
            # For the first poster where we haven't selected a video yet, prefer video (but don't require it if unavailable)
            prefer_video = (not video_selected and poster_idx == 0 and selected_videos)
            
            selected_media = processor.select_best_media_for_poster(
                poster_name,
                prefer_video=prefer_video,
                require_video=False,  # Make video optional for testing with image-only media
                exclude_used=True
            )
            
            if selected_media:
                media_dict[poster_name] = selected_media.file_path
                processor.used_media.add(selected_media.file_path)
                if selected_media.is_video:
                    video_selected = True
                    has_video = True
                print(f"  {poster_name}: {Path(selected_media.file_path).name} ({selected_media.width}x{selected_media.height}, aspect={selected_media.aspect_ratio:.2f}, type={'video' if selected_media.is_video else 'image'})")
            else:
                print(f"  ✗ Could not find suitable media for {poster_name}")
                # Revert used_media for this mod since we're bailing
                for media_path in media_dict.values():
                    processor.used_media.discard(media_path)
                break
        
        # Ensure we got all 6 positions filled and have at least one video
        if len(media_dict) < 6:
            print(f"  ✗ Could not fill all poster positions (got {len(media_dict)}/6)")
            break
        
        if not has_video:
            print(f"  ⚠ No video in this mod (ideally needs ≥1, but proceeding with images only)")
            # Note: In production, you should have at least 1 video per mod for better presentation
        
        # Create mod structure
        if mod_gen.create_mod_structure(mod_config, media_dict):
            # Mark all media as used in version tracker for future runs
            for media_path in media_dict.values():
                mod_gen.version_tracker.mark_media_used(media_path)
            created_mods.append(mod_config)
        else:
            print(f"  ✗ Failed to create mod structure")
            # Revert used_media since structure creation failed
            for media_path in media_dict.values():
                processor.used_media.discard(media_path)
    
    if not created_mods:
        print("✗ No mods were created.")
        return 1
    
    print(f"\n✓ Created {len(created_mods)} mod(s)")
    print()
    
    # Step 4: Create archives
    print("[4/4] Creating mod archives...")
    for mod_config in created_mods:
        archive_path = mod_gen.create_mod_archive(mod_config, args.build)
        if archive_path:
            print(f"  ✓ {mod_config.mod_name}-v{mod_config.version}.zip")
    
    # Save version tracking
    mod_gen.version_tracker.save()
    
    print()
    print("=" * 60)
    print("✓ Generation complete!")
    print("=" * 60)
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
