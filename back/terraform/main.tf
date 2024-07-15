provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "GoAppServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y golang-go",
      "mkdir -p /opt/app",
      "echo '${file("${path.module}/app.tar.gz")}' > /opt/app/app.tar.gz",
      "tar -xvzf /opt/app/app.tar.gz -C /opt/app",
      "cd /opt/app && go run main.go &"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
