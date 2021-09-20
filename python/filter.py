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
        zeros = []
        window_size = 15
        max_amt_zeros = 6
        dz = 10
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
            elif start < (stop_limit-1):
                points = self._find_min_max(data[start:stop_limit-1])
                points[0][0] += start
                points[1][0] += start
                finding_zeros = False
            else:
                finding_zeros = False

            # scaling_factor = ((y2 - y1) / (y2 + y1)) + 1
            # scaling_factor = ((abs(points[1][1])-abs(points[0][1])) / (abs(points[1][1]) +
            #                   abs(points[0][1]) + int((not points[1][1]) & (not points[0][1])))) + 1
            # zero = scaling_factor * (x2-x1) + x1
            zero = (1 * (points[1][0] - points[0][0])/2) + points[0][0]
            zero = int(zero)
            if zero > points[1][0]:
                zero = points[1][0]
            elif zero < points[0][0]:
                zero = points[0][0]
            if zero not in zeros:
                zeros.append(zero)
        return zeros

    def cluster_zeros(self, zeros, pixle_width):
        """
            zeros must be ordered from lowest to highest
        """
        tmp_zeros = []
        clustered_zeros = []
        segment_start = 0
        for i in range(len(zeros)):
            if zeros[i] < (zeros[segment_start] + pixle_width):
                tmp_zeros.append(zeros[i])
            else:
                if len(tmp_zeros):
                    clustered_zeros.append(int(sum(tmp_zeros)/len(tmp_zeros)))
                    tmp_zeros = []
                    tmp_zeros.append(zeros[i])
                    segment_start = i
        if len(tmp_zeros):
            clustered_zeros.append(int(sum(tmp_zeros)/len(tmp_zeros)))
        return clustered_zeros

    def cull_zeros(self, data, zeros, threshold_factor):
        new_zeros = []
        max_val = int(max(data))
        for val in zeros:
            if data[val] > threshold_factor*max_val:
                new_zeros.append(val)
        return new_zeros

    def cull_data(self, data, threshold_factor):
        culled_data = []
        cutoff = int(threshold_factor * max(data))
        for val in data:
            if val > cutoff:
                culled_data.append(val)
            else:
                culled_data.append(0)
        return culled_data

    def _find_min_max(self, sequence):
        y1 = max(sequence)
        y2 = min(sequence)
        for index, val in enumerate(sequence):
            if val == y2:
                x2 = index
            if val == y1:
                x1 = index
        if x2 > x1:
            return([[x1, y1], [x2, y2]])
        else:
            return([[x2, y2], [x1, y1]])


if __name__ == '__main__':
    img = np.transpose(cv.imread("misc/pcog liveimages/pcog liveimages/weld 5000us.png", cv.IMREAD_GRAYSCALE))
    fir = FIRFilter(5, [-3, 12, 17, 12, -3], 35)
    fir2 = FIRFilter(5, [2, 1, 0, -1, -2], 10)
    fir3 = FIRFilter(21, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1], 121)
    smoothed_data = fir.convolve(img[1079])
    smoothed_data = fir3.convolve(smoothed_data)
    # culled_data = fir.cull_data(smoothed_data, 0.8)
    culled_data = smoothed_data
    differentiated_data = fir2.convolve(culled_data)
    tmp_zeros = fir2.detect_zero_crossings(differentiated_data)
    print(len(tmp_zeros))
    zeros = fir.cull_zeros(img[1079], tmp_zeros, 0.8)
    zeros = fir2.cluster_zeros(zeros, 20)
    print(len(zeros))
    fig, ax = plt.subplots(3)
    ax[0].annotate("raw", xy=(0.9, 0.9))
    ax[0].plot(img[1079])
    ax[1].annotate("smoothed+culled", xy=(0.9, 0.9))
    ax[1].plot(culled_data)
    ax[2].annotate("derivative", xy=(0.9, 0.9))
    ax[2].plot(differentiated_data)
    ax[2].scatter(zeros, [0 for i in range(len(zeros))], c='red')
    plt.show()
