# OpenMIPS
用来记录学习《自己动手写CPU》的过程。
* ToolKit 中主要包括编译 MIPS 指令的文件。
    * **Step1**：首先需要将 mips-4.3-221-mips-sde-elf-i686-pc-linux-gnu.tar.bz2 文件解压到 /opt/ 中。
    ![1](./Picture/1.png)
    * **Step2**：之后打开用户主目录 Home 文件夹，通过 ls -a 指令找到隐藏的 .bashrc 文件，使用 gedit 编辑这个文件。
    ![2](./Picture/2.png)
    * **Step3**：在此文件的最后加入 PATH 的设置。
    ![3](./Picture/3.png)
    * **Step4**：重新启动 Ubuntu 系统。重启后，打开终端，在其中输入 mips-sde-elf-，然后按两次 Tab 键，会列出刚刚安装的针对 MIPS 平台的所有编译工具，如下图所示，表示 GNU 工具链安装成功。
    ![4](./Picture/4.png)
    * **Step5**：每次通过 Makefile 完成对 MIPS 指令的编译。Makefile 主要依赖如下的几个文件。
        * inst_rom.S: 这里面包括 MIPS 用到的汇编指令。下面给一个示例：
            ```
            .org 0x0        // 指示程序从地址 0x0 开始
            .global _start  // 定义一个全局符号 _start
            .set noat       // 允许自由使用寄存器 $1
            _start:
                ori $1, $0, 0x1100
                ori $1, $1, 0x0020
                ori $1, $1, 0x4400
                ori $1, $1, 0x0044
            ```
        * ram.ld: 连接描述脚本。
        * Bin2Mem.exe: 由 Bin2Mem.c 文件通过 `gcc ./Bin2Mem.c -o Bin2Mem` 编译生成，需要注意的是在生成 Bin2Mem.exe 文件后要赋予其权限，`chmod 777 Bin2Mem.exe` 否则后面会报错。
    * **Step6**：最终生成 inst_rom.data 文件，可以在 Vivado 中通过 readmemh 完成 rom 的初始化。需要注意的是生成的 inst_rom.data 最后一条指令会重复，因此在进行仿真的过程中需要将最后重复的这条指令删去。
        ![5](./Picture/5.png)

