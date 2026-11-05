# 🐱🐳 Apache Tomcat on Docker (Ubuntu EC2 via PuTTY)

🚀 Deploy a simple JSP page on Apache Tomcat inside a Docker container on an Ubuntu AWS EC2 server, then push the project to GitHub. This guide goes from a blank server to a working project.

## 📁 Project Structure

```
Tomcat-Docker-project/
├── Dockerfile
├── webapp/
│   └── index.jsp
├── images/
│   ├── tomcat-port-8080.png
│   └── tomcat-port-9090.png
└── README.md
```

## ✅ Prerequisites

- ☁️ AWS account with an Ubuntu EC2 instance running
- 🖥️ PuTTY on Windows
- 🐙 GitHub account
- 🌐 Web browser

---

## 🔐 Step 1: Configure the EC2 Security Group

1. AWS Console → **EC2 → Instances** → select your instance.
2. Open the **Security** tab and click the security group.
3. **Edit inbound rules → Add rule** and add:

| Type | Port | Source |
|---|---|---|
| SSH | 22 | My IP |
| Custom TCP | 8080 | 0.0.0.0/0 |
| Custom TCP | 9090 | 0.0.0.0/0 (only if you use port 9090) |

4. Click **Save rules**.

## 🔌 Step 2: Connect with PuTTY

1. Open PuTTY.
2. **Host Name**: your EC2 **Public IPv4 address**. **Port**: `22`. **Connection type**: SSH.
3. In **Connection → SSH → Auth → Credentials**, select your `.ppk` key file.
4. Click **Open** and log in as `ubuntu` (or `root` if your server allows it).

## 🐳 Step 3: Update the Server and Install Docker

```bash
sudo apt update
sudo apt install -y docker.io git
sudo systemctl enable --now docker
```

Verify:

```bash
docker --version
git --version
```

## 📂 Step 4: Create the Project Folder

```bash
mkdir -p ~/tomcat-docker/webapp
cd ~/tomcat-docker
```

> ⚠️ Always run project commands **inside** this folder. Do not run `git init` in your home folder.

## 📝 Step 5: Create the Web Page

```bash
nano webapp/index.jsp
```

Paste this, then save with `Ctrl+O`, `Enter`, and exit with `Ctrl+X`:

```jsp
<html>
  <body>
    <h1>Hello from Tomcat in Docker!</h1>
    <p>Server time: <%= new java.util.Date() %></p>
  </body>
</html>
```

## 🐋 Step 6: Create the Dockerfile

```bash
nano Dockerfile
```

```dockerfile
FROM tomcat:10.1-jdk17
COPY webapp/ /usr/local/tomcat/webapps/ROOT/
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

| Line | Meaning |
|---|---|
| `FROM` | Base image with Tomcat 10.1 and Java 17 already installed |
| `COPY` | Copies your page into Tomcat's `ROOT` folder so it opens at `/` |
| `EXPOSE` | Documents that Tomcat listens on port 8080 |
| `CMD` | Starts Tomcat in the foreground |

## 🔨 Step 7: Build the Docker Image

```bash
docker build -t my-tomcat .
```

## ▶️ Step 8: Run the Container

Standard port 8080:

```bash
docker run -d --name my-tomcat -p 8080:8080 my-tomcat
```

If port 8080 is already used by another Tomcat on the same machine, use 9090 instead:

```bash
docker rm -f my-tomcat
docker run -d --name my-tomcat -p 9090:8080 my-tomcat
```

Check that it is running:

```bash
docker ps
docker logs my-tomcat
```

`docker ps` should show the status as **Up**, and the logs should end with `Server startup in [...] milliseconds`.

## 🧪 Step 9: Test the Application

From the server:

```bash
curl http://localhost:8080
```

From your browser (use the **Public IPv4 address**, not the `172.31...` private one):

```
http://<EC2-public-IP>:8080
```

(or `:9090` if you used that port). 🎉 You should see **Hello from Tomcat in Docker!** with the server time.

### 📸 Screenshot 1: Application running on port 8080

![Tomcat running on port 8080](images/tomcat-port-8080.png)

### 📸 Screenshot 2: Application running on port 9090

![Tomcat running on port 9090](images/tomcat-port-9090.png)

Both screenshots show the same page served by the Docker container, first on the default port `8080` and then on the alternative port `9090`.

## 🐙 Step 10: Push the Project to GitHub

### 10.1 📦 Create the repository
On github.com click **New repository**, name it `Tomcat-Docker-project`, and create it.

### 10.2 ⚙️ Set up Git (first time only)

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

### 10.3 🔑 Create a Personal Access Token
GitHub does not accept your account password for Git. Create a token instead:

1. GitHub → **Settings → Developer settings → Personal access tokens → Tokens (classic)**
2. **Generate new token (classic)**, tick **repo**, set a short expiry
3. Copy the token immediately (it starts with `ghp_`)

### 10.4 ⬆️ Commit and push

```bash
cd ~/tomcat-docker
git init
git add .
git commit -m "Initial commit: Tomcat Docker project"
git branch -M main
git remote add origin https://github.com/<username>/Tomcat-Docker-project.git
git pull origin main --no-rebase --allow-unrelated-histories --no-edit
git push -u origin main
```

When prompted:
- **Username**: your GitHub username
- **Password**: paste the **token** (nothing appears on screen, which is normal)

### 10.5 🔄 Updating later

```bash
git add .
git commit -m "Describe your change"
git push
```

## 🧹 Step 11: Security Cleanup

- 🚫 Never share, screenshot or paste your token anywhere.
- 🗑️ Delete the token on GitHub when finished (Settings → Developer settings → Personal access tokens).
- 🧼 Clear the command history on the server:

```bash
history -c && history -w
```

---

## 🛠️ Useful Docker Commands

```bash
docker ps                 # list running containers
docker ps -a              # list all containers
docker logs -f my-tomcat  # follow live logs
docker stop my-tomcat     # stop the container
docker start my-tomcat    # start it again
docker rm -f my-tomcat    # remove the container
docker images             # list images
```

## ♻️ Updating the Application

After editing files in `webapp/`:

```bash
docker rm -f my-tomcat
docker build -t my-tomcat .
docker run -d --name my-tomcat -p 8080:8080 my-tomcat
```

## 🛡️ Optional: Run as a Non-Root User

Running as root is fine for learning, but a normal user is safer for real projects.

On the server:

```bash
sudo adduser devuser
sudo usermod -aG sudo,docker devuser
su - devuser
```

Inside the container, update the Dockerfile:

```dockerfile
FROM tomcat:10.1-jdk17
COPY webapp/ /usr/local/tomcat/webapps/ROOT/
RUN useradd -r tomcatuser && chown -R tomcatuser /usr/local/tomcat
USER tomcatuser
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

---

## 🩺 Troubleshooting

| Problem | Cause and fix |
|---|---|
| Page does not load in browser | Port not open in the Security Group. Add the inbound rule (Step 1) and use `http://`, not `https://` |
| Using `172.31.x.x` address | That is the private IP. Use the **Public IPv4 address** |
| `permission denied` for docker | Run `sudo usermod -aG docker $USER`, then log out and back in |
| `port is already allocated` | Another service uses the port. Use `-p 9090:8080` |
| Tomcat cat page shows instead of your page | Another Tomcat is running on that port. Use a different port |
| `error: 'tomcat-docker/' does not have a commit checked out` | You ran `git init` in the wrong folder. Run `rm -rf ~/.git`, then `cd ~/tomcat-docker` and start again |
| `src refspec main does not match any` | Branch is named `master`. Run `git branch -M main` |
| `Password authentication is not supported` | Use a Personal Access Token, not your password |
| Token typed as `YOUR_TOKEN` or `PASTE_TOKEN_HERE` | Replace the placeholder with the real token |
| `non-fast-forward` or `divergent branches` | Run `git pull origin main --no-rebase --allow-unrelated-histories --no-edit`, then push again |
| `remote origin already exists` | Run `git remote set-url origin <repo-url>` |

## 👨‍💻 Author

Muthu Ramalingam S
