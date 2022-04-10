# Dynamic height TableView in a Scroll View



learning : https://www.youtube.com/watch?v=INkeINPZddo



#### Problem

1. Put TableView inside to Scroll View
2. Scrolling view does not know how much height the TableView needs

### Solution

1. set a fake height constraint first
2. observe tableview  `contentSize` , update  height constraint to contentSize height

![image-20220410122723424](https://cdn.jsdelivr.net/gh/WingCH/ImageHosting@master/uPic/image-20220410122723424.png)

1. 