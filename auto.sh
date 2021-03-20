#!/bin/bash
# 脚本使用方法  . ./auto.sh
# ###############################

echo '$1' $1

runpush(){

    echo "sleep18s networksetup"

    # # 断开VPN
    echo "sleep 5s"
    networksetup -disconnectpppoeservice "UniVPN"
    sleep 5
    # 连接VPN
    echo "sleep 13s"
    networksetup -connectpppoeservice "UniVPN"
    sleep 13

    # 显示当前IP 地址
    curl -L ip.tool.lu

    # # 显示部分需要信息， 方便查看数据
    cat mine.txt
    git ck -b main
    sleep 2
    echo 'check branch ok'


    git reset --soft HEAD~1
    echo 'git reset --soft HEAD~1'


    # 提交代码
    if env GIT_SSL_NO_VERIFY=true git push --set-upstream origin main -f ; then

        # 成功的记录到文件，先记录在移除， 不然么文件了
        cat mine.txt >> ../pushsuccess.txt 

        cd ../ && mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
        result=$?
        if [ $result -eq 0 ]; then
            echo "已经提交代码，文件移除成功"
        else
            # 文件已经存在， 先删除有文件
            echo "已经提交代码，文件已经存在， 先删除有文件在移除"
            # 返回上一层, 移除文件
            rm -rf ~/Desktop/dustbin/$1

            mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
        fi
        # 删除keychain 信息， 在提交的时候会进行访问
        security delete-internet-password -s github.com
    else
        result=$?
        # 仓库不存在， 密码错误等
        if [ $result -eq 128 ]; then

            cat mine.txt >> ../pusherror.txt

            cd ../ && mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
            result=$?

            if [ $result -eq 0 ]; then
                echo "仓库不存在， 密码错误等，文件移除成功"
            else
                # 文件已经存在， 先删除有文件
                echo "仓库不存在， 密码错误等，文件已经存在， 先删除有文件在移除"
                # 返回上一层, 移除文件
                rm -rf ~/Desktop/dustbin/$1

                mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
            fi

            # 如果失败就不删除
            # 删除keychain 信息， 在提交的时候会进行访问
            security delete-internet-password -s github.com
            
        else
            cd ../ && mv -f ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
            result=$?
            if [ $result -eq 0 ]; then
                echo "push 失败，文件移除成功"
            else
                # 文件已经存在， 先删除有文件
                echo "push 失败，文件已经存在， 先删除有文件在移除"
                # 返回上一层, 移除文件
                rm -rf ~/Desktop/dustbin/$1

                mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
            fi
        fi
        # cd ../
        echo 'git push error'
    fi

}

jumpfile(){
    echo '文件已经push过，不需要重新push'
    # 不需要push的文件移除
    pwd

    cd ../ && mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
    result=$?
    if [ $result -eq 0 ]; then
        echo "文件已经push过，不需要重新push，文件移除成功"
    else
        # 文件已经存在， 先删除有文件
        echo "文件已经push过，不需要重新push，文件已经存在， 先删除有文件在移除"
        # 返回上一层, 移除文件
        rm -rf ~/Desktop/dustbin/$1

        mv ./$1 ~/Desktop/dustbin && cd ~/planA/github/src/downloadspush
    fi

}

# 当前目录就是代码目录了。
pwd

# 判断pushsuccess.txt 是否存在
cat ../pushsuccess.txt

result=$?
if [ $result -eq 0 ]; then
    # 判断是否已经成功上传， 成功的跳过
    grep -q $1 ../pushsuccess.txt && echo "exist" || echo "not exist"
    # 没在文件中查找到成功的数据， 就执行push
    grep -q $1 ../pushsuccess.txt && jumpfile $1 || runpush $1
else
    # 文件不存在，生成文件
    echo "1" >> ../pushsuccess.txt
fi

