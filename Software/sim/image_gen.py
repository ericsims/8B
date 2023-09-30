from PIL import Image

from resizeimage import resizeimage

HEIGHT = 40
WIDTH = 50

data = "#d8"

with open('smiley.jpg', 'r+b') as f:
    with Image.open(f) as image:
        img = resizeimage.resize_cover(image, [WIDTH, HEIGHT])
        #img.save('test-image.jpeg', image.format)

        pixels = img.load()
        for row in range(HEIGHT):
            for col in range(WIDTH):
                if sum(pixels[col,row]) > 255*3/2:
                    #white
                    pass
                else:
                    #black
                    data += ' {},{},'.format(row,col)
                    #print(col,row)


print(data)
