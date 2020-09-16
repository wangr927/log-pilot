config.filebeat 文件用于修改filebeat的output信息、template信息等
entrypoint.py是pilot镜像的启动脚本
filebeat.tpl 是为每个容器生成采集说明，放在prospectors目录下，filebeat实例会监视该目录下生成的配置文件
filebeat-6.8.2 目前无论腾讯ces等还是coding的saas服务均使用 6.8.2


changelog
filebeat.tpl删除了docker.json字段，该字段会导致6.8.2版本filebeat出错