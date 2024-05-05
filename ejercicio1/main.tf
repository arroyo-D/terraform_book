provider "aws" {
  region = "eu-west-1"
  #Access-key -> añadida como variable via export
  #Secret-key -> añadida como variable via export 
}

resource "aws_instance" "example" {

  ami                    = "ami-0dfdc165e7af15242"          #Basica gratis
  instance_type          = "t2.micro"                       #Basica gratis
  vpc_security_group_ids = [aws_security_group.instance.id] # lo añado para que se ponga con el SG que creamos

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    
    # Cambiar el puerto en la configuración de Apache
    sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
    
    # Escribir el contenido de la página de inicio
    echo "Hello World" > /var/www/html/index.html
    
    # Iniciar y habilitar Apache
    systemctl start httpd
    systemctl enable httpd
    EOF
  #<<-EOF ... EOF -> permite crear multilineas sin caracteres de salto de linea 

  user_data_replace_on_change = true
  # user_data_replace_on_change -> sirve para que terraform termine la instancia antigua y genere una nueva, en vez de solo modificarla
  tags = {
    Name = "terraform-ejemplo"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  # Creara un SG que permite las llamadas entrantes TCP en el puerto 8080 desde CIRD 0.0.0.0/0 que representa todas las IPs posibles 

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Esto significa que se permiten conexiones salientes sin restricciones en cuanto al protocolo utilizado (TCP, UDP, ICMP y otros)
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Permite todas las conexiones salientes, lo que incluye acceso al repositorio para descargar paquetes
}
