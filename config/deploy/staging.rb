# Se definen los distintos roles para el despliegue, que pueden distintas instancias de amazon.
role :app, %w{tu_usuario@ec2-tu-ip.us-east-2.compute.amazonaws.com}
role :web, %w{tu_usuario@ec2-tu-ip.us-east-2.compute.amazonaws.com}
role :db,  %w{tu_usuario@ec2-tu-ip.us-east-2.compute.amazonaws.com}

# Se definen los distintos servidores, asociados a un rol para hacer el despliegue.
set :user, "tu_usuario"
server "ec2-tu-ip.us-east-2.compute.amazonaws.com", roles: %w{web}

# Se indica la ubicación de la llave.pem descargada desde amazon. Esto para poder hacer la autenticación por SSH
set :ssh_options, {
    forward_agent: true,
    keys: ["~/.ssh/tu_llave.pem"],
    user: 'tu_usuario'
}