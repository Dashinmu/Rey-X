<?php
// Подключаем файл с настройками базы данных
require_once "./scripts/db_connect.php";

// Устанавливаем заголовок страницы
$page_title = "Регистрация";

// Подключаем общий header
require_once "header.php";

// Проверяем, была ли отправлена форма
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Получаем параметры из формы
    $username = $_POST["username"] ?? '';
    $email = $_POST["email"] ?? '';
    $password = $_POST["password"] ?? '';

    // Генерируем хэш пароля
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Создаем запрос на вставку данных пользователя в базу данных
    $sql = "INSERT INTO users (username, email, password) VALUES ('$username', '$email', '$hashed_password')";

    // Выполняем запрос
    if ($conn->query($sql) === TRUE) {
        echo "Регистрация успешна!";
    } else {
        echo "Ошибка при регистрации: " . $conn->error;
    }
} else {
    echo "Форма не была отправлена."; // Отладочное сообщение
}
?>

<div class="container">
    <form class="form" method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
        <h2>Регистрация</h2>
        <div class="input-container">
            <input type="text" name="username" placeholder="Имя пользователя" required>
        </div>
        <div class="input-container">
            <input type="email" name="email" placeholder="Электронная почта" required>
        </div>
        <div class="input-container">
            <input type="password" name="password" placeholder="Пароль" required>
            <p class="login-text">Уже есть аккаунт? <a href="/login.php">Войти</a></p>
        </div>
        <button type="submit">Зарегистрироваться</button>
    </form>
</div>

<?php
require_once "footer.php"; // Подключаем footer.php
?>