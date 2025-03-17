from PIL import Image
import os

def generate_fnt_file(image_path, char_string, output_path=None):
    """
    Generate a .fnt file from an sfont bitmap image.
    
    Args:
        image_path (str): Path to sfont bitmap image
        char_string (str): String of characters that represent each character in the image
        output_path (str, optional): Path to save the output .fnt file. If None, use the image name.
    """
    # Open and read the image
    try:
        img = Image.open(image_path)
        width, height = img.size
    except Exception as e:
        print(f"Error opening image: {e}")
        return
    
    # Extract character positions from the first row
    first_row = []
    for x in range(width):
        pixel = img.getpixel((x, 0))
        # Check if the pixel is marked (non-transparent)
        if isinstance(pixel, tuple) and len(pixel) == 4:  # RGBA
            if pixel[3] > 0:  # Alpha > 0
                first_row.append(x)
        elif pixel != 0:  # For non-RGBA images, check if pixel is non-zero
            first_row.append(x)
    
    # Calculate character positions
    char_positions = []
    for i in range(len(first_row) - 1):
        start = first_row[i]
        end = first_row[i + 1] - 1
        char_width = end - start + 1
        char_positions.append((start, char_width))
    
    # Check if we have enough characters
    if len(char_positions) > len(char_string):
        print(f"Warning: More characters detected ({len(char_positions)}) than provided in char_string ({len(char_string)})")
        char_positions = char_positions[:len(char_string)]
    elif len(char_positions) < len(char_string):
        print(f"Warning: Fewer characters detected ({len(char_positions)}) than provided in char_string ({len(char_string)})")
        char_string = char_string[:len(char_positions)]
    
    # Generate the .fnt file content
    font_name = os.path.splitext(os.path.basename(image_path))[0]
    image_name = os.path.basename(image_path)
    
    fnt_content = [
        f"info face=\"{font_name}\" size={height-1} bold=0 italic=0 charset=\"\" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0 outline=0",
        f"common lineHeight={height-1} base=0 scaleW={width} scaleH={height} pages=1 packed=0 alphaChnl=0 redChnl=0 greenChnl=0 blueChnl=0",
        f"page id=0 file=\"{image_name}\"",
        f"chars count={len(char_positions)}"
    ]
    
    # Add character definitions
    for i, ((start, char_width), char) in enumerate(zip(char_positions, char_string)):
        char_id = ord(char)
        fnt_content.append(f"char id={char_id} x={start} y=1 width={char_width} height={height-1} xoffset=0 yoffset=0 xadvance={char_width} page=0 chnl=15")
    
    # Add kernings
    fnt_content.append("kernings count=0")
    
    # Write to file
    if output_path is None:
        output_path = os.path.splitext(image_path)[0] + ".fnt"
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(fnt_content))
    
    print(f"Generated .fnt file: {output_path}")
    return output_path

def main():
    # Prompt the user for input
    print("SFont to FNT Converter")
    print("----------------------")
    
    # Get image path
    image_path = input("Enter the path to the sfont bitmap image: ")
    
    # Get character string
    print("Enter the character string (each character represents a glyph in the image):")
    char_string = input()
    
    # Get output path (optional)
    output_path = input("Enter the output path for the .fnt file (or leave blank to use the same name as the image): ")
    if output_path.strip() == "":
        output_path = None
    
    # Generate the .fnt file
    generate_fnt_file(image_path, char_string, output_path)

if __name__ == "__main__":
    main()