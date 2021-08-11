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
            data_buffer = [val] + data_buffer[:-1]  # right shift the buffer by 1
            sum = 0
            for i in range(self.n):
                sum += data_buffer[i] * self.coeff[i]
            output.append(sum/self.normal)
        for _ in range(int(self.n/2)):
            output = output[1:] + [0]
        return output

    def detect_zero_crossings(self, data):
        # max_val = 0
        # min_val = 0
        # max_i = 0
        # min_i = 0
        # for i in range(len(data)):
        #     if data[i] >= max_val:
        #         max_val = data[i]
        #         max_i = i
        #     if data[i] < min_val:
        #         min_val = data[i]
        #         min_i = i
        # return int((min_i-max_i)/2 + max_i)
        zeros = []
        window_size = 15
        start = 0
        stop = window_size - 1
        stop_limit = len(data)
        finding_zeros = True
        while(finding_zeros):
            if stop < stop_limit:
                points = self._find_min_max(data[start:stop])
                points[0][0] += start
                points[1][0] += start
                start += 1
                stop += 1
            else:
                points = self._find_min_max(data[start:stop_limit-1])
                points[0][0] += start
                points[1][0] += start
                finding_zeros = False
            zeros.append(int((points[0][0]+points[1][0])/2))
        return zeros

    def _find_min_max(self, sequence):
        min_val = min(sequence)
        max_val = max(sequence)
        for index, val in enumerate(sequence):
            if val == min_val:
                min_index = index
            if val == max_val:
                max_index = index
        return([[min_index, min_val], [max_index, max_val]])


if __name__ == '__main__':
    img = np.transpose(cv.imread("misc/pcog liveimages/pcog liveimages/weld 5000us.png", cv.IMREAD_GRAYSCALE))
    fir = FIRFilter(5, [-3, 12, 17, 12, -3], 35)
    fir2 = FIRFilter(5, [2, 1, 0, -1, -2], 10)
    # print(max(img[1165]))
    s = fir.convolve(img[1165])
    # threshold = int(0.8*max(img[498]))
    # for i in range(len(s)):
    #     if s[i] < threshold:
    #         s[i] = 0
    # print(max(s))
    v = fir2.convolve(s)
    tmp_zeros = fir.detect_zero_crossings(v)
    zeros = []
    for val in tmp_zeros:
        if img[1165][val] > int(0.5*255):
            zeros.append(val)
    print(len(zeros))
    fig, ax = plt.subplots(3)
    ax[0].annotate("raw", xy=(0.9, 0.9))
    ax[0].plot(img[1165])
    ax[1].annotate("smoothed+culled", xy=(0.9, 0.9))
    ax[1].plot(s)
    ax[2].annotate("derivative", xy=(0.9, 0.9))
    ax[2].plot(v)
    ax[2].scatter(zeros, [0 for i in range(len(zeros))], c='red')
    plt.show()
