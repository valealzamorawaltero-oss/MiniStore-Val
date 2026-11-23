-- ============================================
-- MiniStore - Script de Base de Datos
-- Universidad Antonio José Camacho - PTSI 2026
-- ============================================

CREATE DATABASE IF NOT EXISTS ministore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ministore;

-- ==========================================
-- TABLA: roles
-- ==========================================
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

-- ==========================================
-- TABLA: usuarios
-- ==========================================
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    correo VARCHAR(100),
    id_rol INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- ==========================================
-- TABLA: categorias
-- ==========================================
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

-- ==========================================
-- TABLA: productos
-- ==========================================
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500),
    precio_venta DECIMAL(10,2) NOT NULL,
    precio_costo DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    id_categoria INT,
    imagen_path VARCHAR(300),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- ==========================================
-- TABLA: clientes
-- ==========================================
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    documento VARCHAR(20) UNIQUE,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- TABLA: ventas
-- ==========================================
CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    numero_venta VARCHAR(20) NOT NULL UNIQUE,
    id_cliente INT,
    id_usuario INT NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    impuesto DECIMAL(10,2) DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'COMPLETADA',
    observacion VARCHAR(300),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);


CREATE TABLE IF NOT EXISTS detalle_venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);


INSERT INTO roles (nombre, descripcion) VALUES
('ADMINISTRADOR', 'Acceso total al sistema'),
('VENDEDOR', 'Acceso a ventas y consultas');

-- Password: admin123 (SHA-256)
INSERT INTO usuarios (nombre, username, password, correo, id_rol) VALUES
('Administrador', 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin@ministore.com', 1),
('Vendedor Demo', 'vendedor', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'vendedor@ministore.com', 2);

INSERT INTO categorias (nombre, descripcion) VALUES
('Bebidas', 'Gaseosas, jugos, agua y bebidas en general'),
('Snacks', 'Pasabocas, dulces y mecato'),
('Lácteos', 'Leche, queso, yogurt y derivados'),
('Aseo', 'Productos de limpieza y aseo personal'),
('Granos', 'Arroz, frijoles, lentejas y similares');

INSERT INTO productos (nombre, descripcion, precio_venta, precio_costo, stock, stock_minimo, id_categoria) VALUES
('Coca-Cola 350ml', 'Gaseosa Coca-Cola lata 350ml', 3500.00, 2500.00, 50, 10, 1),
('Agua Cristal 600ml', 'Agua purificada botella 600ml', 2000.00, 1200.00, 100, 20, 1),
('Papas Margarita 30g', 'Papas fritas empaque individual', 2500.00, 1800.00, 60, 15, 2),
('Chocoramo', 'Ponqué de chocolate Ramo', 1500.00, 1000.00, 40, 10, 2),
('Leche Colanta 1L', 'Leche entera Colanta bolsa 1 litro', 3200.00, 2600.00, 30, 10, 3),
('Arroz Diana 500g', 'Arroz blanco Diana 500 gramos', 3800.00, 3000.00, 25, 8, 5),
('Jabón Protex 120g', 'Jabón antibacterial Protex', 4500.00, 3200.00, 20, 5, 4);

INSERT INTO clientes (nombre, documento, direccion, telefono, correo) VALUES
('Cliente General', '0000000', 'Sin dirección', 'Sin teléfono', NULL),
('María García', '12345678', 'Calle 10 # 5-20', '3001234567', 'maria@email.com'),
('Carlos López', '87654321', 'Carrera 5 # 12-30', '3109876543', 'carlos@email.com');


CREATE OR REPLACE VIEW v_productos_stock AS
SELECT p.id_producto, p.nombre, p.precio_venta, p.stock, p.stock_minimo,
       c.nombre AS categoria,
       CASE WHEN p.stock <= p.stock_minimo THEN 'BAJO' ELSE 'OK' END AS estado_stock
FROM productos p
LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.activo = TRUE;

CREATE OR REPLACE VIEW v_ventas_detalle AS
SELECT v.id_venta, v.numero_venta, v.fecha_venta,
       COALESCE(cl.nombre, 'Cliente General') AS cliente,
       u.nombre AS vendedor,
       v.total, v.estado
FROM ventas v
LEFT JOIN clientes cl ON v.id_cliente = cl.id_cliente
JOIN usuarios u ON v.id_usuario = u.id_usuario;