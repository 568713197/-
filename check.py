from skimage import io,transform
import tensorflow as tf
import numpy as np
import os
import glob

flower_dict = {0:'cardboard',1:'glass',2:'metal',3:'paper',4:'plastic',5:'trash'}

w=50
h=50
c=3

def read_one_image(path):
    img = io.imread(path)
    img = transform.resize(img,(w,h))
    return np.asarray(img)

with tf.Session() as sess:
    data = []
    path_test='D:\CNN_demo\data/train/'
    print('Start read the image ...')
    cate = [path_test + x for x in os.listdir(path_test) if os.path.isdir(path_test + x)]
    print(cate)

    for index, folder in enumerate(cate):
        # print(index, folder)
        for im in glob.glob(folder + '/*.jpg'):
            data0 = read_one_image(im)
            data.append(data0)
    print('Finished ...')


    saver = tf.train.import_meta_graph('D:\CNN_demo/model.ckpt.meta')
    saver.restore(sess,tf.train.latest_checkpoint('D:\CNN_demo/'))

    graph = tf.get_default_graph()
    x = graph.get_tensor_by_name("x:0")
    feed_dict={x:data}

    logits = graph.get_tensor_by_name("logits_eval:0")

    classification_result = sess.run(logits,feed_dict)

    #打印出预测矩阵
    print(classification_result)
    #打印出预测矩阵每一行最大值的索引
    print(tf.argmax(classification_result,1).eval())
    #根据索引通过字典对应花的分类
    output = []
    output = tf.argmax(classification_result,1).eval()
    for i in range(len(output)):
        print("第",i+1,"预测:"+flower_dict[output[i]])
