Introduction: 
Atrous convolution is a technique that expands the kernel by inserting holes between its consecutive elements. In simpler terms, it is a special type of convolution that involves pixel skipping to expand the receptive field without increasing parameters. For example, a 3x3 atrous convolution kernel with the hyperparameter dilation=2 can have the same receptive field as a 5x5 regular convolution kernel. By altering the hyperparameter dilation, atrous convolution can capture features at multiple scales. Moreover, atrous convolution can reduce the spatial resolution loss 
compared with regular convolution. Atrous convolutions have been used successfully in various applications, such as semantic segmentation, where a larger context is needed to classify each pixel, and audio processing, where the network needs to learn patterns with longer time dependencies. 
![image](https://github.com/Lin-Yu-Ming/-Atrous-Convolution/assets/71814265/8851ddbe-f1a9-46b6-90f6-00661cd948d7)


Block Diagram


![image](https://github.com/Lin-Yu-Ming/-Atrous-Convolution/assets/71814265/4ab3a5be-4b3a-4148-bc18-453852ba7398)



I/O

![image](https://github.com/Lin-Yu-Ming/-Atrous-Convolution/assets/71814265/27b50bb3-b3c5-47e1-aa7f-a0b1726a647e)
![image](https://github.com/Lin-Yu-Ming/-Atrous-Convolution/assets/71814265/e22e2518-afd8-4455-95b9-510c7768930e)
![image](https://github.com/Lin-Yu-Ming/-Atrous-Convolution/assets/71814265/accdbf1c-6492-477a-8e62-15224d43bd8a)
