import cv2 as cv
import numpy as np

img = np.transpose(cv.imread("misc/pcog liveimages/pcog liveimages/weld 2000us.png", cv.IMREAD_GRAYSCALE))
test_vector = img[1082]
with open("VHDL/test_vectors/i_top_test.txt", 'w') as f:
    for i, pixel in enumerate(test_vector):
        if i == 0:
            f.write(f"1{pixel:02x}\n")
        elif i == (len(test_vector) - 1):
            f.write(f"3{pixel:02x}\n")
        else:
            f.write(f"2{pixel:02x}\n")
