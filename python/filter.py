import cv2 as cv
import numpy as np
import matplotlib.pyplot as plt


class FIRFilter:
    def __init__(self, ncoeffs, coeff, normal) -> None:
        if len(coeff) == ncoeffs:
            self.n = ncoeffs
            self.coeff = coeff
            self.normal = normal
        else:
            print(
                f"number of coefficients provided {ncoeffs} doesn't match the amount of coefficients given {len(coeff)}")

    def convolve(self, data_stream):
        output = []
        data_buffer = []
        for _ in range(self.n):
            data_buffer.append(0)
        for val in data_stream:
            data_buffer = [val] + data_buffer[:-1]  # shift the buffer by 1
            sum = 0
            for i in range(self.n):
                sum += data_buffer[i] * self.coeff[i]
            output.append(sum/self.normal)
        return output

    def detect_zero_crossings(self, data):
        # crossings = []
        # for i in range(len(data)-1):
        #     if (data[i] > 0) and (data[i+1] <= 0):
        #         if((data[i]-data[i+1]) > threshold):
        #             crossings.append(i)
        # return crossings
        max_val = 0
        min_val = 0
        max_i = 0
        min_i = 0
        for i in range(len(data)):
            if data[i] >= max_val:
                max_val = data[i]
                max_i = i
            if data[i] < min_val:
                min_val = data[i]
                min_i = i
        print(max_i, min_i)
        return [int((min_i-max_i)/2 + max_i)]


if __name__ == '__main__':
    img = np.transpose(cv.imread("misc/pcog liveimages/pcog liveimages/sphere 6mm 5000us.png", cv.IMREAD_GRAYSCALE))
    fir = FIRFilter(5, [2, 1, 0, -1, -2], 10)
    v = fir.convolve(img[1000])
    zeros = fir.detect_zero_crossings(v)
    fig, ax = plt.subplots(2)
    ax[0].plot(img[1000])
    ax[1].plot(v)
    ax[1].scatter(zeros, list(np.zeros(len(zeros))), c='red')
    print(fir.detect_zero_crossings(v))
    plt.show()
