# GitHub项目提交指南

## 一、准备工作

### 1.1 安装Git
如果还没有安装Git，请先下载安装：
- Windows: https://git-scm.com/download/win
- Mac: https://git-scm.com/download/mac
- Linux: `sudo apt-get install git`

### 1.2 注册GitHub账号
访问 https://github.com 注册账号（如果还没有的话）

## 二、创建GitHub仓库

### 2.1 登录GitHub
1. 访问 https://github.com
2. 使用你的账号登录

### 2.2 创建新仓库
1. 点击右上角的 "+" 号
2. 选择 "New repository"
3. 填写仓库信息：
   - Repository name: pharma_ease_app
   - Description: 药送送 - 药店管理系统
   - Public/Private: 选择 Public（公开）或 Private（私有）
4. 点击 "Create repository" 按钮

## 三、本地项目初始化

### 3.1 打开项目目录
在命令行中进入你的项目文件夹：
```bash
cd C:/Users/Wyx123/OneDrive/Desktop/pharma_ease_app
```

### 3.2 初始化Git仓库
```bash
git init
```

### 3.3 创建.gitignore文件
在项目根目录创建 .gitignore 文件，忽略不需要提交的文件：
```
# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# iOS related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3

# Coverage
coverage/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
```

## 四、提交代码到GitHub

### 4.1 添加所有文件到暂存区
```bash
git add .
```

### 4.2 创建首次提交
```bash
git commit -m "Initial commit: 药送送药店管理系统"
```

### 4.3 添加远程仓库
```bash
git remote add origin https://github.com/你的用户名/pharma_ease_app.git
```
**注意**：将"你的用户名"替换为你的GitHub用户名

### 4.4 推送到GitHub
```bash
git branch -M main
git push -u origin main
```

## 五、后续更新代码

### 5.1 查看修改状态
```bash
git status
```

### 5.2 添加修改的文件
```bash
git add .
# 或添加特定文件
git add 文件名
```

### 5.3 提交修改
```bash
git commit -m "描述你的修改内容"
```

### 5.4 推送到GitHub
```bash
git push
```

## 六、常用Git命令

### 6.1 查看提交历史
```bash
git log
```

### 6.2 查看当前分支
```bash
git branch
```

### 6.3 创建新分支
```bash
git branch 分支名
```

### 6.4 切换分支
```bash
git checkout 分支名
```

### 6.5 合并分支
```bash
git merge 分支名
```

### 6.6 拉取最新代码
```bash
git pull
```

## 七、注意事项

### 7.1 提交信息规范
- 使用清晰、简洁的提交信息
- 首行简短描述（不超过50字符）
- 空一行后添加详细说明
- 示例：
  ```
  feat: 添加购物车功能

  - 实现添加商品到购物车
  - 支持修改商品数量
  - 支持删除商品
  ```

### 7.2 敏感信息
- 不要提交包含密码的文件
- 不要提交API密钥
- 不要提交个人配置文件

### 7.3 文件大小
- 单个文件不超过100MB
- 大文件使用Git LFS（Large File Storage）

## 八、常见问题

### 8.1 认证失败
如果遇到认证失败，使用个人访问令牌：
1. GitHub -> Settings -> Developer settings
2. Personal access tokens -> Generate new token
3. 选择需要的权限
4. 生成后使用令牌代替密码

### 8.2 推送失败
如果推送失败，尝试：
```bash
git pull --rebase
git push
```

### 8.3 忽略已跟踪的文件
```bash
git rm --cached 文件名
git commit -m "Remove file from tracking"
```

## 九、项目README建议

在GitHub仓库中创建README.md文件，包含：
- 项目简介
- 功能特点
- 安装说明
- 使用方法
- 技术栈
- 截图展示
- 贡献指南
- 许可证信息

## 十、完成检查清单

提交前确认：
- [ ] 代码已测试通过
- [ ] .gitignore配置正确
- [ ] 提交信息清晰明了
- [ ] 没有提交敏感信息
- [ ] README文件已创建
- [ ] 项目结构清晰
- [ ] 注释完整

完成以上步骤后，你的项目就成功上传到GitHub了！
