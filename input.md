
---

● 发现问题了！你的系统键盘布局设置不一致：

     - X11 布局是 cn（中文）
     - 当前 setxkbmap 显示是 us（美式）

   这可能导致你输入密码时某些字符被错误映射。试试这些解决方案：

   方法1：在终端中临时测试输入

     # 先看看你实际输入的是什么
     read -s pass && echo "$pass" | od -c
     # 输入你的密码后看字符编码是否正确

   方法2：统一键盘布局

     # 临时切换到美式键盘
     setxkbmap us
     # 然后再试 sudo

   方法3：如果密码包含特殊字符，用 passwd 重设

     # 以 root 身份重设密码（需要物理访问或恢复模式）

   你想先试试哪个方法？或者告诉我你的密码中是否包含特殊符号（如 @#$% 等），这样我能更准确地判断问题。
   git clone http://localhost:2080/datamanageplatform/datamanagebackend.git
   
