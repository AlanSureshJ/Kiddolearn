from PIL import Image
import os

# Set this to your number image directory
IMAGE_FOLDER = 'assets/numbers/'

def add_white_background(image_path, output_path):
    img = Image.open(image_path).convert("RGBA")
    background = Image.new("RGBA", img.size, (255, 255, 255, 255))
    background.paste(img, (0, 0), img)
    background.convert("RGB").save(output_path, "PNG")

def process_all_images():
    for filename in os.listdir(IMAGE_FOLDER):
        if filename.lower().endswith('.png'):
            file_path = os.path.join(IMAGE_FOLDER, filename)
            print(f'Processing: {filename}')
            add_white_background(file_path, file_path)  # Overwrites original

if __name__ == "__main__":
    process_all_images()
    print("✅ All images processed and now have a white background.")