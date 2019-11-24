from skimage import io, transform
import glob
import os
import tensorflow as tf
import numpy as np
import time

# 数据集地址
path = 'D:\waste_dataset/'
# 模型保存地址
model_path = 'D:\model.ckpt'

# 将所有的图片resize成100*100
w = 32
h = 32
c = 3
def Record_Tensor(tensor,name):
	print ("Recording tensor "+name+" ...")
	f = open('./dat_final/'+name+'.dat', 'w')
	array=tensor.eval();
	#print ("The range: ["+str(np.min(array))+":"+str(np.max(array))+"]")
	if(np.size(np.shape(array))==1):
		Record_Array1D(array,name,f)
	else:
		if(np.size(np.shape(array))==2):
			Record_Array2D(array,name,f)
		else:
			if(np.size(np.shape(array))==3):
				Record_Array3D(array,name,f)
			else:
				Record_Array4D(array,name,f)
	f.close();

def Record_Array1D(array,name,f):
	for i in range(np.shape(array)[0]):
		f.write(str(array[i])+"\n")

def Record_Array2D(array,name,f):
	for i in range(np.shape(array)[0]):
		for j in range(np.shape(array)[1]):
			f.write(str(array[i][j])+"\n")

def Record_Array3D(array,name,f):
	for i in range(np.shape(array)[0]):
		for j in range(np.shape(array)[1]):
			for k in range(np.shape(array)[2]):
				f.write(str(array[i][j][k])+"\n")

def Record_Array4D(array,name,f):
	for i in range(np.shape(array)[0]):
		for j in range(np.shape(array)[1]):
			for k in range(np.shape(array)[2]):
				for l in range(np.shape(array)[3]):
					f.write(str(array[i][j][k][l])+"\n")

# 读取图片
def read_img(path):
    cate = [path + x for x in os.listdir(path) if os.path.isdir(path + x)]
    imgs = []
    labels = []
    for idx, folder in enumerate(cate):
        for im in glob.glob(folder + '/*.jpg'):
            # print('reading the images:%s'%(im))
            img = io.imread(im)
            img = transform.resize(img, (w, h))
            imgs.append(img)
            labels.append(idx)
    return np.asarray(imgs, np.float32), np.asarray(labels, np.int32)


data, label = read_img(path)

# 打乱顺序
num_example = data.shape[0]
arr = np.arange(num_example)
np.random.shuffle(arr)
data = data[arr]
label = label[arr]

# 将所有数据分为训练集和验证集
ratio = 0.8
s = np.int(num_example * ratio)
x_train = data[:s]
y_train = label[:s]
x_val = data[s:]
y_val = label[s:]

# -----------------构建网络----------------------
# 占位符
x = tf.placeholder(tf.float32, shape=[None, w, h, c], name='x')
y_ = tf.placeholder(tf.int32, shape=[None, ], name='y_')


def inference(input_tensor, train):
    with tf.variable_scope('layer1-conv1'):
        conv1_weights = tf.get_variable("weight", [3, 3, 3, 16],
                                        initializer=tf.truncated_normal_initializer(stddev=0.1))
        conv1_biases = tf.get_variable("bias", [16], initializer=tf.constant_initializer(0.0))
        conv1 = tf.nn.conv2d(input_tensor, conv1_weights, strides=[1, 1, 1, 1], padding='SAME')
        relu1 = tf.nn.relu(tf.nn.bias_add(conv1, conv1_biases))

    with tf.name_scope("layer2-pool1"):
        pool1 = tf.nn.max_pool(relu1, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding="SAME")

    with tf.variable_scope("layer3-conv2"):
        conv2_weights = tf.get_variable("weight", [3, 3, 16, 32],
                                        initializer=tf.truncated_normal_initializer(stddev=0.1))
        conv2_biases = tf.get_variable("bias", [32], initializer=tf.constant_initializer(0.0))
        conv2 = tf.nn.conv2d(pool1, conv2_weights, strides=[1, 1, 1, 1], padding='SAME')
        relu2 = tf.nn.relu(tf.nn.bias_add(conv2, conv2_biases))

    with tf.name_scope("layer4-pool2"):
        pool2 = tf.nn.max_pool(relu2, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')
        nodes = 8 * 8 * 32
        reshaped = tf.reshape(pool2, [-1, nodes])

    with tf.variable_scope('layer9-fc1'):
        fc1_weights = tf.get_variable("weight", [nodes, 128],
                                      initializer=tf.truncated_normal_initializer(stddev=0.1))
        fc1_biases = tf.get_variable("bias", [128], initializer=tf.constant_initializer(0.1))

        fc1 = tf.nn.relu(tf.matmul(reshaped, fc1_weights) + fc1_biases)
        if train: fc1 = tf.nn.dropout(fc1, 0.5)

    with tf.variable_scope('layer11-fc3'):
        fc3_weights = tf.get_variable("weight", [128, 5],
                                      initializer=tf.truncated_normal_initializer(stddev=0.1))
        fc3_biases = tf.get_variable("bias", [5], initializer=tf.constant_initializer(0.1))
        logit = tf.matmul(fc1, fc3_weights) + fc3_biases

    return logit,conv1_weights,conv1_biases,conv2_weights,conv2_biases,fc1_weights,fc1_biases,fc3_weights,fc3_biases


# ---------------------------网络结束---------------------------
logits,conv1_weights,conv1_biases,conv2_weights,conv2_biases,fc1_weights,fc1_biases,fc3_weights,fc3_biases = inference(x, False)

# (小处理)将logits乘以1赋值给logits_eval，定义name，方便在后续调用模型时通过tensor名字调用输出tensor
b = tf.constant(value=1, dtype=tf.float32)
logits_eval = tf.multiply(logits, b, name='logits_eval')
W_conv1 = tf.multiply(conv1_weights, b, name='W_conv1')
b_conv1 = tf.multiply(conv1_biases, b, name='b_conv1')
W_conv2 = tf.multiply(conv2_weights, b, name='W_conv2')
b_conv2 = tf.multiply(conv2_biases, b, name='b_conv2')
W_fc1   = tf.multiply(fc1_weights, b, name='W_fc1')
b_fc1   = tf.multiply(fc1_biases, b, name='b_fc1')
W_fc2   = tf.multiply(fc3_weights, b, name='W_fc2')
b_fc2   = tf.multiply(fc3_biases, b, name='b_fc2')
loss = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits, labels=y_)
train_op = tf.train.AdamOptimizer(learning_rate=0.001).minimize(loss)
correct_prediction = tf.equal(tf.cast(tf.argmax(logits, 1), tf.int32), y_)
acc = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))


# 定义一个函数，按批次取数据
def minibatches(inputs=None, targets=None, batch_size=None, shuffle=False):
    assert len(inputs) == len(targets)
    if shuffle:
        indices = np.arange(len(inputs))
        np.random.shuffle(indices)
    for start_idx in range(0, len(inputs) - batch_size + 1, batch_size):
        if shuffle:
            excerpt = indices[start_idx:start_idx + batch_size]
        else:
            excerpt = slice(start_idx, start_idx + batch_size)
        yield inputs[excerpt], targets[excerpt]


# 训练和测试数据，可将n_epoch设置更大一些

n_epoch = 125
batch_size = 200
saver = tf.train.Saver()
sess = tf.Session()
sess.run(tf.global_variables_initializer())
for epoch in range(n_epoch):
    start_time = time.time()

    # training
    train_loss, train_acc, n_batch = 0, 0, 0
    for x_train_a, y_train_a in minibatches(x_train, y_train, batch_size, shuffle=True):
        _, err, ac = sess.run([train_op, loss, acc], feed_dict={x: x_train_a, y_: y_train_a})
        train_loss += err;
        train_acc += ac;
        n_batch += 1
    print('第 %d 次训练' % (epoch + 1))
    print("   train loss: %f" % (np.sum(train_loss) / n_batch))
    print("   train acc: %f" % (np.sum(train_acc) / n_batch))
    print('************************************************')

    # validation
    val_loss, val_acc, n_batch = 0, 0, 0
    for x_val_a, y_val_a in minibatches(x_val, y_val, batch_size, shuffle=False):
        err, ac = sess.run([loss, acc], feed_dict={x: x_val_a, y_: y_val_a})
        val_loss += err;
        val_acc += ac;
        n_batch += 1
    print('测试训练准确度')
    print("   validation loss: %f" % (np.sum(val_loss) / n_batch))
    print("   validation acc: %f" % (np.sum(val_acc) / n_batch))
    print('************************************************')
saver.save(sess, model_path)
with sess.as_default():
	Record_Tensor(W_conv1, "W_conv1")
	Record_Tensor(b_conv1, "b_conv1")
	Record_Tensor(W_conv2, "W_conv2")
	Record_Tensor(b_conv2, "b_conv2")
	#Record_Tensor(W_conv3, "W_conv3")
	#Record_Tensor(b_conv3, "b_conv3")
	#Record_Tensor(W_conv4, "W_conv4")
	#Record_Tensor(b_conv4, "b_conv4")
	Record_Tensor(W_fc1, "W_fc1")
	Record_Tensor(b_fc1, "b_fc1")
	Record_Tensor(W_fc2, "W_fc2")
	Record_Tensor(b_fc2, "b_fc2")
	#Record_Tensor(W_fc3, "W_fc3")
	#Record_Tensor(b_fc3, "b_fc3")
sess.close()
