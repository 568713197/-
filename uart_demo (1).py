
# coding: utf-8

# In[1]:


from pynq.overlays.base import BaseOverlay
from pynq.lib import MicroblazeLibrary
base = BaseOverlay('base.bit')
print('finish')


# In[28]:


lib = MicroblazeLibrary(base.RPI, ['uart'])
device = lib.uart_open(14,15)

list2 = [101]
for num in range(10,20):
    lib.uart_write(device,list2, len(list2))
number=[101,110]
flag=0
flag1=0
while(1):
    if(base.buttons[3].read()==1):
        if(flag==0):
            print(number)
        flag=1
        #lib.uart_read(device,number,len(number))
        lib.uart_write(device,number,len(number))
    lib.uart_read(device,number,len(number))
    if(base.buttons[1].read()==1&flag1==0):
        flag1==1
        lib.uart_read(device,number,len(number))
        print(number)
    elif(base.buttons[0].read()==1):
        break
base.rgbleds[5].write(2)


# In[41]:


number=[101,110]
list2=[chr(i) for i in number] #使用列表推导式把列表中的单个元素全部转化为str类型
print(list2)
print(str(list2))
str4 = "".join(list2)
print(str4)

