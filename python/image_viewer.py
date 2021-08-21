import sys
import tkinter as tk
from tkinter.constants import END, INSERT
from tkinter import filedialog
import cv2 as cv
from PIL import ImageTk, Image
import numpy as np
import matplotlib
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk
import re
from filter import FIRFilter


class ImageViewer:
    def __init__(self, index='') -> None:
        # vars
        self.THRESHOLD = 0.8

        matplotlib.use("TkAgg")
        self.master = tk.Tk()
        self.master.title("Image Viewer " + index)
        self.setup_viewer()
        self.create_filters()
        self.master.mainloop()

    def setup_viewer(self):
        w, h = self.master.winfo_screenwidth(), self.master.winfo_screenheight()
        self.master.geometry("%dx%d+0+0" % (w, h))
        self.master.config(bg="white")
        self.master.bind("<Escape>", self.close)
        self.unfiltered_image_label = tk.Label(self.master, text='Please choose an image',
                                               font="Times 20 roman bold", bg='grey')
        self.unfiltered_image_label.pack()
        self.unfiltered_image_label.place(relheight=0.3, relwidth=0.5, relx=0.02, rely=0.13)
        self.filtered_image_label = tk.Label(self.master, text='test text',
                                             font="Times 20 roman bold", bg='grey')
        self.filtered_image_label.pack()
        self.filtered_image_label.place(relheight=0.3, relwidth=0.5, relx=0.02, rely=0.53)
        self.image_path_label = tk.Text(self.master, bg='grey', border=2,
                                        state="normal", borderwidth=1, relief="sunken")
        self.image_path_label.insert(INSERT, "Path")
        self.image_path_label.delete('1.0', END)
        self.image_path_label.insert(INSERT, "path2")
        self.image_path_label.pack()
        self.image_path_label.place(relheight=0.04, relwidth=0.38, relx=0.6, rely=0.15)
        self.browse_image_box = tk.Button(self.master, bg='grey', text='Browse Image', command=self.browse_image)
        self.browse_image_box.pack()
        self.browse_image_box.place(relheight=0.04, relwidth=0.1, relx=0.74, rely=0.21)
        self.apply_filter_box = tk.Button(self.master, bg='grey', text='Apply filter', command=self.filter_image)
        self.apply_filter_box.pack()
        self.apply_filter_box.place(relheight=0.04, relwidth=0.1, relx=0.74, rely=0.27)
        self.save_filtered_box = tk.Button(
            self.master, bg='grey', text='Save filtered image', command=self.save_filtered_img)
        self.save_filtered_box.pack()
        self.save_filtered_box.place(relheight=0.04, relwidth=0.1, relx=0.74, rely=0.33)

    def browse_image(self, *_args):
        self.image_path = filedialog.askopenfilename(
            initialdir='.', title="Select Image", filetypes=(("PNG", "*.png"), ("all files", "*.*")))
        print(self.image_path)
        self.image_path_label.delete('1.0', END)
        self.image_path_label.insert(INSERT, self.image_path)
        self.show_image()

    def show_image(self):
        self.image = np.transpose(cv.imread(self.image_path, cv.IMREAD_GRAYSCALE))
        self.unfiltered_image = self._resize_image(np.transpose(self.image), self.unfiltered_image_label)
        self.unfiltered_image = self._convert_to_PIL_image(cv.cvtColor(self.unfiltered_image, cv.COLOR_GRAY2RGB))
        self.unfiltered_image_label.config(image=self.unfiltered_image)

    def filter_image(self):
        zeros = []
        for column in range(len(self.image)):
            s = self.filter_1.convolve(self.image[column])
            s = self.filter_2.convolve(s)
            zeros.append(self.filter_2.cull_zeros(self.image[column],
                         self.filter_2.detect_zero_crossings(s), self.THRESHOLD))
        self.image = np.transpose(self.image)
        self.image = cv.cvtColor(self.image, cv.COLOR_GRAY2RGB)
        for i in range(self.image.shape[1]):
            for j in range(len(zeros[i])):
                self.image[zeros[i][j]][i] = [255, 0, 0]

        self.filtered_fullrez_img = np.copy(self.image)
        self.image = self._resize_image(self.image, self.filtered_image_label)
        self.image = self._convert_to_PIL_image(self.image)
        self.filtered_image_label.config(image=self.image)
        self.plot_zeros(zeros)

    def plot_zeros(self, zeros):
        fig = Figure(figsize=(5, 5), dpi=100)
        self.zeros_plot = fig.add_subplot(111)
        x = []
        y = []
        for column in range(len(zeros)):
            for row in zeros[column]:
                x.append(column)
                y.append(row)
        self.zeros_plot.scatter(x, y, c='red')
        self.zeros_plot.set_title("vertical position of the laser beam")

        zeros_canvas = FigureCanvasTkAgg(fig, self.master)
        zeros_canvas.draw()
        toolbar = NavigationToolbar2Tk(zeros_canvas, self.master, pack_toolbar=False)
        toolbar.place(relwidth=0.4, relx=0.6, rely=0.83)
        toolbar.update()
        zeros_canvas.get_tk_widget().place(relheight=0.3, relwidth=0.4, relx=0.6, rely=0.53)

    def save_filtered_img(self, *_args):
        img_name = re.findall('(?<=\/)[\w\s.]*(?=\.png)', self.image_path)[0]
        self.filtered_image_directory = filedialog.asksaveasfilename(initialdir='.', initialfile=f"{img_name}_filtered", defaultextension=".png", filetypes=(
            ("PNG", "*.png"), ("all files", "*.*")))
        saved_image = Image.fromarray(self.filtered_fullrez_img)
        saved_image.save(self.filtered_image_directory)

    def create_filters(self):
        self.filter_1 = FIRFilter(5, [-3, 12, 17, 12, -3], 35)
        self.filter_2 = FIRFilter(5, [2, 1, 0, -1, -2], 10)

    def close(self, *_args):
        self.master.destroy()
        sys.exit(0)

    def _image_cut(self):
        self.image_sections = [0]
        stop = False
        while(not stop):
            if (self.image_sections[-1] + 10) <= self.image.shape[0]:
                self.image_sections.append(self.image_sections[-1] + 10)
            else:
                for i in range(10):
                    if (self.image_sections[-1] + (9 - i)) <= self.image.shape[0]:
                        self.image_sections.append(self.image_sections[-1] + 9 - i)
                        stop = True
                        break
        self.image_sections = self.image_sections[1:]

    def _convert_to_PIL_image(self, img):
        return ImageTk.PhotoImage(image=Image.fromarray(img))

    def _resize_image(self, img, master):
        return cv.resize(img, (master.winfo_width(), master.winfo_height()), interpolation=cv.INTER_LINEAR)


if __name__ == '__main__':
    ImageViewer()
