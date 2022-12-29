# 第六章：移动操作指令的实现
## 1、HI、LO 寄存器
HI、LO 寄存器用于保存乘法、除法结果。当用于保存乘法结果时，HI 寄存器保存结果的高 32 位， LO 寄存器保存结果的低 32 位；当用于保存除法结果时，HI 寄存器保存余数，LO 寄存器保存商。

<div align=center><img src=./Picture/1.png width = 80% ></div>

当加入这两个特殊寄存器后，又会引入新的数据相关问题。例如在上面的图中，指令 3、4、5 均要修改 HI 寄存器，当指令 6 处于执行阶段时，指令 5 处于访存阶段，指令 4 处于回写阶段，而此时 HI 寄存器的值是指令 3 刚刚写入的数据，HILO 模块正是将该值传到执行阶段，如果采用这个值，那么就会出错，偏离程序设想，正确的值应该是当前处于访存阶段的指令 5 要写的数据。因此需要按照类似上一章的思路修改数据流图如下，相比如 [Chapter5](https://github.com/cpyhal3515/OpenMIPS/tree/main/Chapter5) 中的数据流图，下面的数据流图增加了红色的部分
<div align=center><img src=./Picture/2.png width = 80% ></div>
根据上面的流水线示意图可以得到如下所示的模块连接结构示意图：
<div align=center><img src=./Picture/3.png width = 80% ></div>

## 2、移动操作指令的说明
<div align=center><img src=./Picture/4.png width = 80% ></div>

### （1）movn、movz
* `movn rd, rs, rt`，如果通用寄存器 rt 中的值不为零，就将地址为 rs 的通用寄存器的值赋给地址为 rd 的通用寄存器，反之则保持地址为 rd 的通用寄存器不变。
* `movz rd, rs, rt`，如果通用寄存器 rt 中的值为零，就将地址为 rs 的通用寄存器的值赋给地址为 rd 的通用寄存器，反之则保持地址为 rd 的通用寄存器不变。

### （2）mfhi、mflo、mthi、mtlo
* `mfxx`，用法 `mfxx rd` 将特殊寄存器 `xx` 的值赋给地址为 `rd` 的通用寄存器。
* `mtxx`，用法 `mtxx rs` 将地址为 `rs` 的通用寄存器的值赋给特殊寄存器 `xx`。



