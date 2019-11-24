from skimage import io,transform
import tensorflow as tf
import numpy as np
import os
import glob
import cv2
path1 = "D:\CNN_demo\data\\valid\cardboard\cardboard4.jpg"
path2 = "D:\CNN_demo\data\\train\metal\metal7.jpg"
path3 = "D:\CNN_demo\data\\train\glass\glass67.jpg"
path4 = "D:\CNN_demo\data\\train\paper\paper19.jpg"
path5 = "D:\CNN_demo\data\\train\plastic\plastic18.jpg"

flower_dict = {0:'cardboard',1:'glass',2:'metal',3:'paper',4:'plastic'}

w=32
h=32
c=3

def read_one_image(path):
    img = io.imread(path)
    #img =cv2.imread(path)

    img = transform.resize(img,(w,h))

    img_32 = img.astype(np.float32)
    print(img_32.dtype)

    return np.asarray(img_32)

with tf.Session() as sess:
    data = []
    path_test = 'D:\CNN_demo\TA/'
    print('Start read the image ...')
    cate = [path_test + x for x in os.listdir(path_test) if os.path.isdir(path_test + x)]
    print(cate)

    for index, folder in enumerate(cate):
        # print(index, folder)
        for im in glob.glob(folder + '/*.jpg'):
            data0 = read_one_image(im)
            print(data0)
            data.append(data0)
    print('Finished ...')


    saver = tf.train.import_meta_graph('D:\model.ckpt.meta')
    saver.restore(sess,tf.train.latest_checkpoint('D:/'))

    graph =tf.compat.v1.get_default_graph()
    x = graph.get_tensor_by_name("x:0")
    feed_dict ={x:data}
    logits = graph.get_tensor_by_name("logits_eval:0")
    W_conv1 = graph.get_tensor_by_name("W_conv1:0")
    b_conv1 = graph.get_tensor_by_name("b_conv1:0")
    '''
    W_conv2 = tf.multiply(conv2_weights, b, name='W_conv2')
    b_conv2 = tf.multiply(conv2_biases, b, name='b_conv2')
    W_fc1 = tf.multiply(fc1_weights, b, name='W_fc1')
    b_fc1 = tf.multiply(fc1_biases, b, name='b_fc1')
    W_fc2 = tf.multiply(fc3_weights, b, name='W_fc2')
    b_fc2 = tf.multiply(fc3_biases, b, name='b_fc2')
    '''
    w_conv1 = sess.run(W_conv1)
    b_conv1 = sess.run(b_conv1)
    classification_result = sess.run(logits,feed_dict)

    #打印出预测矩阵
    #print(w_conv1)
    #print(b_conv1)
    print(classification_result)
    #打印出预测矩阵每一行最大值的索引
    print(tf.argmax(classification_result,1).eval())
    #根据索引通过字典对应花的分类
    output = []
    output = tf.argmax(classification_result,1).eval()
    for i in range(len(output)):
        print("第",i+1,"预测:"+flower_dict[output[i]])
