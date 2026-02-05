<?php
include 'db.php';

$steam_stmt = $pdo->query("SELECT title, genre, price, discount, players, image_url, url 
                           FROM steam_games ORDER BY id ASC LIMIT 5");
$steam_games = $steam_stmt->fetchAll(PDO::FETCH_ASSOC);

$meta_stmt = $pdo->query("SELECT title, genre, metascore, user_score, image_url, url 
                          FROM metacritic_games ORDER BY id ASC LIMIT 5");
$meta_games = $meta_stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="UTF-8">
  <title>Top Games</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      margin: 0; padding: 0;
      background: #f4f4f9;
      color: #333;
    }
    header {
      background: #2c3e50;
      color: #fff;
      text-align: center;
      padding: 20px;
      font-size: 1.5em;
      width: 100%;
      box-sizing: border-box;
    }
    section {
     padding: 20px 5%; /* ใช้ % แทนค่าคงที่เพื่อให้ยืดหยุ่นตามหน้าจอ */
     width: 100%;
     box-sizing: border-box;
    }
    h2 {
      border-left: 5px solid #3498db;
      padding-left: 10px;
      color: #2c3e50;
    }
    .grid {
      display: grid;
  /* ปรับ minmax ให้เล็กลงเล็กน้อยเพื่อให้ยัด Card ได้มากขึ้นในแถวเดียวเมื่อจอใหญ่ */
      grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); 
      gap: 20px;
      margin-top: 15px;
      width: 100%;
    }
    .card {
      background: #fff;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      padding: 15px;
      transition: transform .2s;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      text-align: center;
    }
    .card:hover { transform: scale(1.02); }
    .card a { text-decoration: none; color: inherit; }
    .card img {
      width: 100%;
      height: 160px;
      object-fit: cover;
      border-radius: 8px;
      margin-bottom: 10px;
    }
    .title { font-weight: bold; margin-bottom: 5px; font-size: 1.1em; }
    .genre { font-size: 0.9em; color: #555; margin-bottom: 10px; }
    
    .meta-box {
      display: flex;
      flex-direction: column;
      gap: 5px;
      text-align: left;
      font-size: 0.9em;
      min-height: 80px;
    }
    
    .btn-main {
      display: inline-block;
      margin: 30px auto;
      background: linear-gradient(135deg, #3498db, #2ecc71);
      color: #fff;
      padding: 14px 30px;
      text-decoration: none;
      border-radius: 50px;
      font-size: 1.2em;
      font-weight: bold;
      box-shadow: 0 4px 10px rgba(0,0,0,0.2);
      transition: all 0.3s ease;
    }
    .btn-main:hover {
      background: linear-gradient(135deg, #2ecc71, #3498db);
      transform: scale(1.08);
      box-shadow: 0 6px 14px rgba(0,0,0,0.3);
    }
    .btn-container { text-align: center; }

    footer {
      background: #2c3e50;
      color: #fff;
      text-align: center;
      padding: 10px;
      margin-top: 20px;
    }
  </style>
</head>
<body>
<header> การพัฒนาระบบการจัดอันดับ
เกมผ่านเทคนิคการสกัดข้อมูลจากเว็บด้วยภาษาไพธอน
 </header>

<section>
  <h2>Steam Games</h2>
  <div class="grid">
    <?php foreach ($steam_games as $game): ?>
      <div class="card">
        <a href="<?= htmlspecialchars($game['url']) ?>" target="_blank">
          <?php if (!empty($game['image_url'])): ?>
            <img src="<?= htmlspecialchars($game['image_url']) ?>" alt="<?= htmlspecialchars($game['title']) ?>">
          <?php endif; ?>
          <div class="title"><?= htmlspecialchars($game['title']) ?></div>
        </a>
        <div class="genre"><?= htmlspecialchars($game['genre']) ?></div>
        <div class="meta-box">
          <div>ราคา: <?= $game['price'] ?></div>
          <div>ส่วนลด: <?= $game['discount'] ?>%</div>
          <div>ผู้เล่น: <?= $game['players'] ?></div>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
</section>

<section>
  <h2>Metacritic Games</h2>
  <div class="grid">
    <?php foreach ($meta_games as $game): ?>
      <div class="card">
        <a href="<?= htmlspecialchars($game['url']) ?>" target="_blank">
          <?php if (!empty($game['image_url'])): ?>
            <img src="<?= htmlspecialchars($game['image_url']) ?>" alt="<?= htmlspecialchars($game['title']) ?>">
          <?php endif; ?>
          <div class="title"><?= htmlspecialchars($game['title']) ?></div>
        </a>
        <div class="genre"><?= htmlspecialchars($game['genre']) ?></div>
        <div class="meta-box">
          <div>Metascore: <?= $game['metascore'] ?></div>
          <div>User Score: <?= $game['user_score'] ?></div>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
</section>

<div class="btn-container">
  <a href="allpage.php" class="btn-main"> ดูเกมทั้งหมด </a>
</div>

<footer>
  &copy; <?= date("Y") ?> ระบบดึงข้อมูลเกมจากเว็บไซต์
</footer>
</body>
</html>
