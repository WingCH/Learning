import json
import os
import yaml
import sys
from pathlib import Path

'''
riverpod_doc_from_firecrawl.json is downloaded from firecrawl playground

this script will convert the single json file to multiple markdown files
python process_json_to_md.py riverpod_doc_from_firecrawl.json
'''

def sanitize_filename(title):
    # Remove invalid filename characters
    invalid_chars = '<>:"/\\|?*'
    filename = ''.join(c for c in title if c not in invalid_chars)
    return filename.strip()

def process_json_to_md(json_path):
    # Convert to Path object
    json_path = Path(json_path)
    output_dir = json_path.parent / 'markdown_output'
    
    # Get JSON filename
    json_filename = json_path.name
    
    # Read the JSON file
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Create output directory if it doesn't exist
    output_dir.mkdir(exist_ok=True)

    # Process each item
    for item in data:
        if 'metadata' not in item:
            continue

        # Get title from metadata or use a default
        title = item['metadata'].get('title', 'Untitled')
        
        # Create sanitized filename
        filename = sanitize_filename(title)
        filepath = output_dir / f"{filename}.md"

        # Prepare the content
        frontmatter = yaml.dump(item['metadata'], allow_unicode=True)
        markdown_content = item.get('markdown', '')

        # Write to file
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('---\n')  # Start frontmatter
            f.write(f'# Generated from firecrawl: {json_filename}\n')  # Add source comment
            f.write(frontmatter)
            f.write('---\n\n')  # End frontmatter
            f.write(markdown_content)

        print(f"Created: {filepath}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process_json_to_md.py <path_to_json_file>")
        sys.exit(1)
    
    json_path = sys.argv[1]
    process_json_to_md(json_path)