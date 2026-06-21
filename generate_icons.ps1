# 应用图标生成脚本
# 用法: 把你的图标文件命名为 app_icon.png 放到项目根目录，然后运行此脚本

param(
    [string]$SourceIcon = "E:\coding_test_learning\opencode\trans-flutter\app_icon.png"
)

$resDir = "E:\coding_test_learning\opencode\trans-flutter\android\app\src\main\res"

# 检查源文件是否存在
if (-not (Test-Path $SourceIcon)) {
    Write-Host "错误: 找不到图标文件 $SourceIcon" -ForegroundColor Red
    Write-Host "请把你的图标文件命名为 app_icon.png 放到 E:\coding_test_learning\opencode\trans-flutter\ 目录下" -ForegroundColor Yellow
    exit 1
}

# 使用 Flutter 的 Dart 来调整图片大小
$dartScript = @"
import 'dart:io';
import 'dart:typed_data';

void main() async {
  // 这里需要用 image 包来处理，但为了简单，我们直接复制文件
  // 用户需要手动调整尺寸或者使用在线工具
  
  final source = File('${$SourceIcon.replaceAll('\', '/')}');
  if (!await source.exists()) {
    print('Source file not found');
    exit(1);
  }
  
  print('Source file found: ${source.path}');
  print('Please use an online tool to resize the icon to required sizes');
}
"@

Write-Host "=== 应用图标生成工具 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "源文件: $SourceIcon" -ForegroundColor Green
Write-Host ""
Write-Host "需要生成以下尺寸的图标:" -ForegroundColor Yellow
Write-Host "  - mipmap-mdpi: 48x48"
Write-Host "  - mipmap-hdpi: 72x72"
Write-Host "  - mipmap-xhdpi: 96x96"
Write-Host "  - mipmap-xxhdpi: 144x144"
Write-Host "  - mipmap-xxxhdpi: 192x192"
Write-Host ""

# 创建临时目录
$tempDir = "E:\coding_test_learning\opencode\trans-flutter\temp_icons"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

Write-Host "请使用以下在线工具调整图标尺寸:" -ForegroundColor Cyan
Write-Host "  https://www.iloveimg.com/resize-image" -ForegroundColor Blue
Write-Host "  https://imageresizer.com/" -ForegroundColor Blue
Write-Host ""
Write-Host "调整后，把图标放到对应的文件夹:" -ForegroundColor Yellow
Write-Host "  $resDir\mipmap-mdpi\ic_launcher.png (48x48)"
Write-Host "  $resDir\mipmap-hdpi\ic_launcher.png (72x72)"
Write-Host "  $resDir\mipmap-xhdpi\ic_launcher.png (96x96)"
Write-Host "  $resDir\mipmap-xxhdpi\ic_launcher.png (144x144)"
Write-Host "  $resDir\mipmap-xxxhdpi\ic_launcher.png (192x192)"
Write-Host ""

# 提示是否要直接复制（不调整大小）
$choice = Read-Host "是否直接复制源文件到所有文件夹? (y/n)"
if ($choice -eq 'y') {
    $sizes = @("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")
    foreach ($size in $sizes) {
        $targetDir = "$resDir\mipmap-$size"
        $targetFile = "$targetDir\ic_launcher.png"
        $targetRound = "$targetDir\ic_launcher_round.png"
        
        Copy-Item -Path $SourceIcon -Destination $targetFile -Force
        Copy-Item -Path $SourceIcon -Destination $targetRound -Force
        
        Write-Host "已复制到: $targetFile" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "完成! 请运行 flutter clean && flutter build apk --release" -ForegroundColor Green
}
