resource "aws_db_instance" "mydb" {
  engine            = "mysql"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  username          = "admin"
  password          = "password123"
  db_name           = "mydatabase"
  multi_az          = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  db_subnet_group_name   = aws_db_subnet_group.main.id
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}
