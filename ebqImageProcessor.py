import os
import requests
from wand.image import Image
from wand.color import Color

def remove_background(input_path, server_url):
    response = requests.post(server_url, files={'file': open(input_path, 'rb')})
    if response.status_code == 200:
        return Image(blob=response.content)
    else:
        raise Exception(f"Failed to remove background, status code: {response.status_code}")

def add_padding(image):
    image.trim()
    image.reset_coords()
    
    max_dimension = max(image.width, image.height)
    new_width = int(max_dimension * 1.2)
    new_height = int(max_dimension * 1.2)
    
    with Image(width=new_width, height=new_height, background=Color('white')) as canvas:
        left = (new_width - image.width) // 2
        top = (new_height - image.height) // 2
        canvas.composite(image, left=left, top=top)
        return canvas

def process_images(input_dir, output_dir, server_url):
    for filename in os.listdir(input_dir):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, f"{os.path.splitext(filename)[0]}.png")
            
            print(f"Processing {filename}")
            try:
                img = remove_background(input_path, server_url)
                final_img = add_padding(img)
                final_img.save(filename=output_path)
            except Exception as e:
                print(e)

if __name__ == "__main__":
    INPUT_DIR = 'input'
    OUTPUT_DIR = 'output'
    SERVER_URL = 'http://192.168.16.37:7000/api/remove'

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    process_images(INPUT_DIR, OUTPUT_DIR, SERVER_URL)
