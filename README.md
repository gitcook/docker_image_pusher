# Docker Images Pusher

使用Github Action将国外的Docker镜像转存到阿里云私有仓库，供国内服务器使用，免费易用<br>
- 支持DockerHub, gcr.io, k8s.io, ghcr.io等任意仓库<br>
- 支持最大40GB的大型镜像<br>
- 使用阿里云的官方线路，速度快<br>

视频教程：https://www.bilibili.com/video/BV1Zn4y19743/

作者：**[技术爬爬虾](https://github.com/tech-shrimp/me)**<br>
B站，抖音，Youtube全网同名，转载请注明作者<br>

## 使用方式


### 配置阿里云
登录阿里云容器镜像服务<br>
https://cr.console.aliyun.com/<br>
启用个人实例，创建一个命名空间（**ALIYUN_NAME_SPACE**）
![](/doc/命名空间.png)

访问凭证–>获取环境变量<br>
用户名（**ALIYUN_REGISTRY_USER**)<br>
密码（**ALIYUN_REGISTRY_PASSWORD**)<br>
仓库地址（**ALIYUN_REGISTRY**）<br>

![](/doc/用户名密码.png)


### Fork本项目
Fork本项目<br>
#### 启动Action
进入您自己的项目，点击Action，启用Github Action功能<br>
#### 配置环境变量
进入Settings->Secret and variables->Actions->New Repository secret
![](doc/配置环境变量.png)
将上一步的**四个值**<br>
ALIYUN_NAME_SPACE,ALIYUN_REGISTRY_USER，ALIYUN_REGISTRY_PASSWORD，ALIYUN_REGISTRY<br>
配置成环境变量

### 添加镜像
打开images.txt文件，添加你想要的镜像 
可以加tag，也可以不用(默认latest)<br>
可添加 --platform=xxxxx 的参数指定镜像架构<br>
可使用 k8s.gcr.io/kube-state-metrics/kube-state-metrics 格式指定私库<br>
可使用 #开头作为注释<br>
![](doc/images.png)
文件提交后，自动进入Github Action构建

### 使用镜像
回到阿里云，镜像仓库，点击任意镜像，可查看镜像状态。(可以改成公开，拉取镜像免登录)
![](doc/开始使用.png)

在国内服务器pull镜像, 例如：<br>
```
docker pull registry.cn-hangzhou.aliyuncs.com/shrimp-images/alpine
```
registry.cn-hangzhou.aliyuncs.com 即 ALIYUN_REGISTRY(阿里云仓库地址)<br>
shrimp-images 即 ALIYUN_NAME_SPACE(阿里云命名空间)<br>
alpine 即 阿里云中显示的镜像名<br>

### 多架构
需要在images.txt中用 --platform=xxxxx手动指定镜像架构
指定后的架构会以前缀的形式放在镜像名字前面
![](doc/多架构.png)

### 镜像重名
永远保留命名空间 ，这样方便用脚本来快速拉取，和tag

* ddsderek/xiaoya-emd:latest -> registry.aliyuncs.com/your-namespace/ddsderek_xiaoya-emd:latest
* nginx:1.25.3 -> registry.aliyuncs.com/your-namespace/library_nginx:1.25.3
* bitnami/nginx:1.25.3 -> registry.aliyuncs.com/your-namespace/bitnami_nginx:1.25.3

程序自动判断是否存在名称相同, 但是属于不同命名空间的情况。
如果存在，会把命名空间作为前缀加在镜像名称前。
例如:
```
xhofe/alist
xiaoyaliu/alist
```
1. 对于 nginx:1.25.3：
因为有多个命名空间的 nginx（library/nginx, kasmweb/nginx, bitnami/nginx）
推送到阿里云的镜像名会是：registry.aliyuncs.com/your-namespace/library_nginx:1.25.3<br>
2. 对于 kasmweb/nginx:1.25.3：
因为 nginx 镜像存在命名空间冲突
推送到阿里云的镜像名会是：registry.aliyuncs.com/your-namespace/kasmweb_nginx:1.25.3<br>
3. 对于 bitnami/nginx:1.25.3：
因为 nginx 镜像存在命名空间冲突
推送到阿里云的镜像名会是：registry.aliyuncs.com/your-namespace/bitnami_nginx:1.25.3<br>
4. 对于 redis:7.2.4：
因为 redis 镜像只有一个命名空间(library)
推送到阿里云的镜像名会是：registry.aliyuncs.com/your-namespace/redis:7.2.4<br>
5. 对于 mcr.microsoft.com/dotnet/aspnet:7.0：
因为 aspnet 镜像没有命名空间冲突
推送到阿里云的镜像名会是：registry.aliyuncs.com/your-namespace/aspnet:7.0<br>
![](doc/镜像重名.png)

### 定时执行
修改/.github/workflows/docker.yaml文件
添加 schedule即可定时执行(此处cron使用UTC时区)
![](doc/定时执行.png)
