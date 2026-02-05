<?php
include 'db.php';

// 1. รับค่าการจัดเรียงจาก URL (ถ้ามี)
$sort_by = $_GET['sort'] ?? 'score';
$sort_dir = $_GET['dir'] ?? 'desc';

// ตรวจสอบและกำหนดค่าเริ่มต้นที่ถูกต้อง
if (!in_array($sort_by, ['title', 'source', 'release_date', 'score'])) {
    $sort_by = 'score';
}
if (!in_array($sort_dir, ['asc', 'desc'])) {
    $sort_dir = 'desc';
}

// 2. รับค่า FILTER จาก URL (ถ้ามี)
$filter_source = $_GET['filter_source'] ?? '';
$filter_min_score = $_GET['filter_min_score'] ?? '';
$filter_date_dir = $_GET['filter_date_dir'] ?? ''; // 'newest' หรือ 'oldest'

// ดึง Steam & Metacritic (โค้ดเดิม)
// ดึง Steam (review_percent เป็น INT อยู่แล้วตาม SQL dump)
$steam_stmt = $pdo->query("SELECT id, title, review_percent, price, discount, release_date, image_url, url 
                               FROM steam_games ORDER BY id ASC");
$steam_games = $steam_stmt->fetchAll(PDO::FETCH_ASSOC);

// ดึง Metacritic (ใช้ Alias 'user_review' ให้ตรงกับคอลัมน์ 'User_review' ใน SQL)
$meta_stmt = $pdo->query("SELECT id, title, metascore, User_review as user_review, release_date, image_url, url 
                             FROM metacritic_games ORDER BY id ASC");
$meta_games = $meta_stmt->fetchAll(PDO::FETCH_ASSOC);

$all_games = [];

// รวม Steam (โค้ดเดิม)
foreach ($steam_games as $g) {
    // เปลี่ยนจาก empty() เป็นการเช็คว่ามีค่าอยู่จริงหรือไม่ เพื่อรองรับคะแนน 0
    $percent = ($g['review_percent'] !== null) ? intval($g['review_percent']) : null;
    
    $all_games[] = [
        'id' => "steam_" . $g['id'],
        'title' => $g['title'],
        'release_date' => $g['release_date'],
        'image_url' => $g['image_url'],
        'source' => 'Steam',
        'score' => $percent, // เก็บเป็นตัวเลข INT
        'price' => $g['price'],
        'discount' => $g['discount'],
        'url' => $g['url'],
        'metascore' => null,
        'user_review' => null
    ];
}

// รวม Metacritic (โค้ดเดิม)
foreach ($meta_games as $g) {
    $percent = null;
    if ($g['user_review'] !== null && $g['user_review'] !== '') {
        // ดึงเฉพาะตัวเลขจาก string เช่น "99%"
        preg_match('/(\d+)/', $g['user_review'], $m);
        if ($m) $percent = intval($m[1]);
    }
    $all_games[] = [
        'id' => "meta_" . $g['id'],
        'title' => $g['title'],
        'release_date' => $g['release_date'],
        'image_url' => $g['image_url'],
        'source' => 'Metacritic',
        'score' => $percent,
        'price' => null,
        'discount' => null,
        'url' => $g['url'],
        'metascore' => $g['metascore'],
        'user_review' => $g['user_review']
    ];
}

// 3. ใช้ array_filter เพื่อกรองข้อมูล
$all_games = array_filter($all_games, function($g) use ($filter_source, $filter_min_score) {
    // กรองตาม Source (เหมือนเดิม)
    if ($filter_source !== '' && $g['source'] !== $filter_source) {
        return false;
    }

    // กรองตาม Score ขั้นต่ำ (ปรับปรุงใหม่)
    if ($filter_min_score !== '') { // ถ้ามีการพิมพ์ตัวเลขลงในช่อง
        $min_val = (int)$filter_min_score;
        // ถ้าเกมไม่มีคะแนน (null) หรือคะแนนน้อยกว่าค่าที่กำหนด ให้กรองออก
        if ($g['score'] === null || $g['score'] < $min_val) {
            return false;
        }
    }

    return true;
});

// 4. จัดเรียงตามวันที่ (ถ้ามีการกำหนด filter_date_dir)
if ($filter_date_dir) {
    usort($all_games, function($a, $b) use ($filter_date_dir) {
        $a_date = strtotime($a['release_date'] ?: '1970-01-01');
        $b_date = strtotime($b['release_date'] ?: '1970-01-01');

        $comparison = $a_date <=> $b_date;
        return $filter_date_dir === 'newest' ? -$comparison : $comparison; // newest = desc
    });
    
    // ตั้งค่า $sort_by/dir เป็น 'none' เพื่อไม่ให้แสดงลูกศร Sort ซ้อนกัน
    $sort_by = 'none';
    $sort_dir = 'none'; 
} else {
    // 5. จัดเรียงตามคอลัมน์ (โค้ดเดิม)
    usort($all_games, function($a, $b) use ($sort_by, $sort_dir) {
        $a_val = $a[$sort_by] ?? ($sort_by === 'score' ? 0 : '');
        $b_val = $b[$sort_by] ?? ($sort_by === 'score' ? 0 : '');
        
        if ($sort_by === 'release_date') {
            $a_val = strtotime($a_val ?: '1970-01-01');
            $b_val = strtotime($b_val ?: '1970-01-01');
        }

        $comparison = 0;
        if ($a_val < $b_val) {
            $comparison = -1;
        } elseif ($a_val > $b_val) {
            $comparison = 1;
        }

        return $sort_dir === 'desc' ? -$comparison : $comparison;
    });
}

// อัปเดตตัวแปรสำหรับส่งไปยัง JavaScript/HTML
$current_sort_by = $sort_by;
$current_sort_dir = $sort_dir;

?>
<!DOCTYPE html>
<html lang="th">
<head>
  <meta charset="UTF-8">
  <title>Game Ranking</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    /* ... CSS ส่วนเดิม ... */
    :root{
      --primary:#3498db;
      --accent:#27ae60;
      --bg:#f4f6f9;
      --card:#fff;
      --muted:#7a8a97;
    }
    *{box-sizing:border-box}
    body { font-family: 'Segoe UI', sans-serif; margin:0; padding:0; background:var(--bg); color:#222; -webkit-font-smoothing:antialiased; }
    header { background:#2c3e50; color:#fff; padding:14px 18px; display:flex; justify-content:center; align-items:center; position:relative; }
    header h1 { margin:0; font-size:1.15rem; font-weight:600; letter-spacing:0.2px; }
    header a.back { position:absolute; left:14px; top:10px; background:var(--primary); color:#fff; padding:8px 12px; border-radius:8px; text-decoration:none; font-size:0.9rem; box-shadow:0 4px 10px rgba(0,0,0,0.12); }
    header a.back:hover { background:#2980b9; }
    #update-btn { position:absolute; right:14px; top:10px; background:var(--accent); color:#fff; border:none; padding:8px 12px; border-radius:8px; cursor:pointer; font-size:0.9rem; box-shadow:0 4px 10px rgba(0,0,0,0.12); }
    #update-btn[disabled] { opacity:0.6; cursor:not-allowed; }

    main { max-width:1100px; margin:18px auto; padding:0 12px 64px; }

    .table-wrap { overflow:auto; border-radius:10px; box-shadow:0 6px 18px rgba(0,0,0,0.06); background:var(--card); }
    table { width:100%; border-collapse:collapse; min-width:760px; }
    thead th { text-align:left; padding:12px 14px; background:linear-gradient(90deg,var(--primary),#2b87c8); color:#fff; font-weight:600; font-size:0.95rem; position:sticky; top:0; z-index:3; }
    tbody td { padding:12px 14px; border-bottom:1px solid #eef3f7; vertical-align:middle; font-size:0.95rem; color:#253242; }
    tbody tr:hover { background:#f5fbff; cursor:pointer; }
    .col-rank { width:56px; font-weight:700; color:var(--muted); }
    .game-info { display:flex; align-items:center; gap:12px; }
    .game-thumb { width:52px; height:52px; border-radius:8px; overflow:hidden; flex-shrink:0; background:#e9eef3; display:inline-block; }
    .game-thumb img { width:100%; height:100%; object-fit:cover; display:block; }
    .meta-small { color:var(--muted); font-size:0.88rem; }

    /* CSS สำหรับ Sorting */
    thead th[data-sort-col] { cursor:pointer; position:relative; padding-right:24px; }
    thead th[data-sort-col]:hover { background:linear-gradient(90deg,#2b87c8,var(--primary)); }
    thead th[data-sort-col]::after { 
        content:'↕'; 
        position:absolute; right:10px; top:50%; transform:translateY(-50%); 
        font-size:0.8rem; color:rgba(255,255,255,0.5); transition:color 0.1s;
    }
    thead th[data-sort-col][data-sort-dir="asc"]::after { content:'▲'; color:#fff; font-size:0.7rem; }
    thead th[data-sort-col][data-sort-dir="desc"]::after { content:'▼'; color:#fff; font-size:0.7rem; }
    thead th[data-sort-dir="none"]::after { content:'↕'; color:rgba(255,255,255,0.5); }
    
    /* **CSS ใหม่สำหรับ Filter Form** */
    #filter-form { 
        display:flex; gap:15px; margin-bottom:18px; padding:15px; 
        background:var(--card); border-radius:10px; box-shadow:0 2px 8px rgba(0,0,0,0.05);
        flex-wrap:wrap;
    }
    #filter-form label { font-size:0.9rem; font-weight:600; color:#333; margin-bottom:4px; display:block; }
    #filter-form select, #filter-form input[type="number"], #filter-form button {
        padding:8px 12px; border-radius:6px; border:1px solid #ddd; font-size:0.9rem;
        transition:border-color 0.2s;
    }
    #filter-form select:focus, #filter-form input:focus { border-color:var(--primary); outline:none; }
    .filter-group { flex-grow:1; min-width:140px; }
    #filter-form button { 
        background:var(--accent); color:#fff; cursor:pointer; font-weight:600;
        border:none; align-self:flex-end; height:38px;
    }
    #filter-form button.reset { background:#7a8a97; }

    /* Modal styles same as before */
    .modal { display:none; position:fixed; inset:0; background:rgba(10,13,19,0.55); align-items:center; justify-content:center; z-index:1200; padding:18px; }
    .modal-inner { background:#fff; width:820px; max-width:100%; border-radius:12px; overflow:hidden; display:flex; gap:0; box-shadow:0 12px 40px rgba(13,20,30,0.25); transform:translateY(6px); }
    .modal-left { flex:0 0 200px; background:#f8fafc; padding:18px; display:flex; flex-direction:column; align-items:center; gap:12px; }
    .modal-left .cover { width:100%; border-radius:8px; overflow:hidden; }
    .modal-left .cover img { width:100%; height:260px; object-fit:cover; display:block; border-radius:8px; }
    .modal-right { padding:18px; flex:1 1 auto; position:relative; }
    .modal-right h2 { margin:0 0 8px 0; font-size:1.2rem; }
    .close { position:absolute; top:12px; right:12px; width:36px; height:36px; border-radius:8px; display:inline-flex; align-items:center; justify-content:center; background:#f1f3f5; cursor:pointer; border:none; font-size:18px; }
    .close:hover { background:#e7eaec; }

    .detail-row { display:flex; gap:8px; margin:8px 0; align-items:flex-start; }
    .detail-label { min-width:118px; color:var(--muted); font-weight:600; }
    .detail-val { flex:1; }
    .btn-row { margin-top:14px; display:flex; gap:10px; align-items:center; }
    .btn-link { display:inline-block; background:var(--primary); color:#fff; padding:8px 12px; border-radius:8px; text-decoration:none; font-weight:600; }
    .btn-outline { background:transparent; border:1px solid #d6e6f8; padding:8px 12px; border-radius:8px; color:#2b3f52; text-decoration:none; }

    @media (max-width:720px){
      .modal-inner { flex-direction:column; }
      .modal-left .cover img { height:200px; }
      .modal-left { flex-basis:auto; width:100%; }
      #filter-form button { margin-top:10px; }
    }
  </style>
</head>
<body>
<header>
  <a href="index.php" class="back">⬅ กลับหน้าหลัก</a>
  <h1>การพัฒนาระบบการจัดอันดับเกมผ่านเทคนิคการสกัดข้อมูลจากเว็บด้วยภาษาไพธอน</h1>
  <button id="update-btn"> Update DB</button>
</header>

<main>
    <form id="filter-form" method="GET" action="">
        <div class="filter-group">
            <label for="filter_source">Source</label>
            <select name="filter_source" id="filter_source">
                <option value="">ทั้งหมด</option>
                <option value="Steam" <?= $filter_source === 'Steam' ? 'selected' : '' ?>>Steam</option>
                <option value="Metacritic" <?= $filter_source === 'Metacritic' ? 'selected' : '' ?>>Metacritic</option>
            </select>
        </div>
        
        <div class="filter-group">
            <label for="filter_min_score">Min User Score (%)</label>
            <input type="number" name="filter_min_score" id="filter_min_score" min="0" max="100" placeholder="เช่น 90" value="<?= htmlspecialchars($filter_min_score) ?>">
        </div>

        <div class="filter-group">
            <label for="filter_date_dir">Release Date</label>
            <select name="filter_date_dir" id="filter_date_dir">
                <option value="">ไม่กรองตามวันที่</option>
                <option value="newest" <?= $filter_date_dir === 'newest' ? 'selected' : '' ?>>ใหม่สุดไปเก่าสุด</option>
                <option value="oldest" <?= $filter_date_dir === 'oldest' ? 'selected' : '' ?>>เก่าสุดไปใหม่สุด</option>
            </select>
        </div>

        <button type="submit" id="apply-filter-btn">✅ Apply Filter</button>
        <button type="button" class="reset" onclick="window.location.href=window.location.pathname;">❌ Reset</button>
        
        <input type="hidden" name="sort" id="hidden_sort" value="<?= htmlspecialchars($current_sort_by) ?>">
        <input type="hidden" name="dir" id="hidden_dir" value="<?= htmlspecialchars($current_sort_dir) ?>">
    </form>
    <div class="table-wrap" role="region" aria-label="Game ranking table">
    <table>
      <thead>
        <tr>
          <th class="col-rank">#</th>
          <th data-sort-col="title" data-sort-dir="<?= ($current_sort_by === 'title' ? $current_sort_dir : 'none') ?>">Game</th>
          <th data-sort-col="source" data-sort-dir="<?= ($current_sort_by === 'source' ? $current_sort_dir : 'none') ?>">Source</th>
          <th data-sort-col="release_date" data-sort-dir="<?= ($current_sort_by === 'release_date' ? $current_sort_dir : 'none') ?>">Release Date</th>
          <th data-sort-col="score" data-sort-dir="<?= ($current_sort_by === 'score' ? $current_sort_dir : 'none') ?>">User Score</th>
        </tr>
      </thead>
      <tbody>
        <?php $rank=1; foreach ($all_games as $g): ?>
          <tr data-gameid="<?= htmlspecialchars($g['id']) ?>" onclick="openModal('<?= htmlspecialchars($g['id']) ?>')">
            <td class="col-rank"><?= $rank++ ?></td>
            <td>
              <div class="game-info">
                <span class="game-thumb">
                  <img src="<?= htmlspecialchars($g['image_url'] ?: 'placeholder.jpg') ?>" alt="thumb">
                </span>
                <div>
                  <div style="font-weight:700;"><?= htmlspecialchars($g['title']) ?></div>
                </div>
              </div>
            </td>
            <td><?= htmlspecialchars($g['source']) ?></td>
            <td><?= htmlspecialchars($g['release_date'] ?: '-') ?></td>
            <td>
              <span style="font-weight:700;"><?= htmlspecialchars($g['score']!==null?$g['score'].'%':'-') ?></span>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</main>

<?php foreach ($all_games as $g): 
   $modalId = 'modal-' . htmlspecialchars($g['id']);
   $cover = htmlspecialchars($g['image_url'] ?: 'placeholder.jpg');
?>
<div class="modal" id="<?= $modalId ?>" aria-hidden="true">
  <div class="modal-inner" role="dialog" aria-modal="true" aria-labelledby="title-<?= $modalId ?>">
    <div class="modal-left">
      <div class="cover">
        <img src="<?= $cover ?>" alt="cover">
      </div>
      <div style="width:100%; text-align:center; margin-top:8px;">
        <div style="font-weight:700;"><?= htmlspecialchars($g['title']) ?></div>
        <div class="meta-small" style="margin-top:6px;"><?= htmlspecialchars($g['source']) ?></div>
      </div>
    </div>

    <div class="modal-right">
      <button class="close" aria-label="Close" onclick="closeModal('<?= $modalId ?>')">&times;</button>
      <h2 id="title-<?= $modalId ?>"><?= htmlspecialchars($g['title']) ?></h2>

      <?php if ($g['source'] === 'Steam'): ?>
        <div class="detail-row"><div class="detail-label">Review %</div><div class="detail-val"><?= htmlspecialchars($g['score']!==null?$g['score'].'%':'-') ?></div></div>
        <div class="detail-row"><div class="detail-label">Price</div><div class="detail-val"><?= htmlspecialchars($g['price'] ?: '-') ?></div></div>
        <div class="detail-row"><div class="detail-label">Discount</div><div class="detail-val"><?= htmlspecialchars($g['discount'] ?: '-') ?></div></div>
        <div class="detail-row"><div class="detail-label">Release Date</div><div class="detail-val"><?= htmlspecialchars($g['release_date'] ?: '-') ?></div></div>
        <div class="btn-row">
          <a class="btn-link" href="<?= htmlspecialchars($g['url']) ?>" target="_blank" rel="noopener">Open on Steam</a>
          <a class="btn-outline" href="javascript:void(0)" onclick="closeModal('<?= $modalId ?>')">Close</a>
        </div>
      <?php else: ?>
        <div class="detail-row"><div class="detail-label">Review %</div><div class="detail-val"><?= htmlspecialchars($g['score']!==null?$g['score'].'%':'-') ?></div></div>
        <div class="detail-row"><div class="detail-label">Meta Score</div><div class="detail-val"><?= htmlspecialchars($g['metascore'] ?: '-') ?></div></div>
        <div class="detail-row"><div class="detail-label">User Review (Raw)</div><div class="detail-val"><?= htmlspecialchars($g['user_review'] ?: '-') ?></div></div>
        <div class="detail-row"><div class="detail-label">Release Date</div><div class="detail-val"><?= htmlspecialchars($g['release_date'] ?: '-') ?></div></div>
        <div class="btn-row">
          <a class="btn-link" href="<?= htmlspecialchars($g['url']) ?>" target="_blank" rel="noopener">Open on Metacritic</a>
          <a class="btn-outline" href="javascript:void(0)" onclick="closeModal('<?= $modalId ?>')">Close</a>
        </div>
      <?php endif; ?>
    </div>
  </div>
</div>
<?php endforeach; ?>

<script>
  // **โค้ด JavaScript ที่แก้ไข: อัปเดตค่า sort/dir ใน form ก่อน submit**
  document.querySelectorAll('th[data-sort-col]').forEach(header => {
    header.addEventListener('click', function() {
      const sortCol = this.getAttribute('data-sort-col');
      let sortDir = this.getAttribute('data-sort-dir');
      
      let newDir = 'asc';
      if (sortDir === 'asc') {
        newDir = 'desc';
      } else if (sortCol === 'score' && sortDir === 'none') {
        newDir = 'desc';
      }

      // **แทนที่จะเปลี่ยน URL โดยตรง ให้กำหนดค่าใน Hidden Input ของ Form แทน**
      document.getElementById('hidden_sort').value = sortCol;
      document.getElementById('hidden_dir').value = newDir;
      
      // ยกเลิกการเลือก 'Release Date' ใน Filter Form เพื่อไม่ให้การ Sort คอลัมน์ขัดแย้งกับการ Filter วันที่
      document.getElementById('filter_date_dir').value = '';
      
      // Submit Form
      document.getElementById('filter-form').submit();
    });
  });

  // **Modal functions (เหมือนเดิม)**
  function openModal(id){
    const el = document.getElementById('modal-' + id);
    if(!el) return;
    el.style.display = 'flex';
    el.setAttribute('aria-hidden','false');
    document.body.style.overflow = 'hidden';
  }
  function closeModal(modalId){
    const el = document.getElementById(modalId);
    if(!el) return;
    el.style.display = 'none';
    el.setAttribute('aria-hidden','true');
    document.body.style.overflow = '';
  }
  window.addEventListener('click', (ev)=>{
    document.querySelectorAll('.modal').forEach(m=>{
      if(m.style.display === 'flex' && ev.target === m){
        m.style.display = 'none';
        m.setAttribute('aria-hidden','true');
        document.body.style.overflow = '';
      }
    });
  });

  // **Update DB function (เหมือนเดิม)**
  const updateBtn = document.getElementById('update-btn');
  updateBtn.addEventListener('click', async ()=>{
    if(!confirm('ต้องการอัปเดตข้อมูลตารางจากแหล่งข้อมูลปัจจุบันหรือไม่?\n(จะไม่อัปเดตรูปภาพ)')) return;
    updateBtn.disabled = true;
    const prevText = updateBtn.textContent;
    updateBtn.textContent = 'กรุณารอสักครู่...';
    try {
      await fetch('update_data.php', { method:'POST' });
    } catch (e) {
      console.error('Update failed', e);
      alert('Update failed: ' + e.message);
    } finally {
      updateBtn.disabled = false;
      updateBtn.textContent = prevText;
    }
  });

  document.addEventListener('keydown', (e)=>{
    if(e.key === 'Escape'){
      document.querySelectorAll('.modal').forEach(m=>{
        if(m.style.display === 'flex'){
          m.style.display = 'none';
          m.setAttribute('aria-hidden','true');
        }
      });
      document.body.style.overflow = '';
    }
  });
</script>
</body>
</html>