from PIL import Image
import os
from pathlib import Path

def optimize_image(input_path, output_path, max_width=800, quality=85):
    """
    优化图片大小
    :param input_path: 输入图片路径
    :param output_path: 输出图片路径
    :param max_width: 最大宽度
    :param quality: 图片质量（1-100）
    """
    try:
        with Image.open(input_path) as img:
            # 计算新的尺寸
            if img.width > max_width:
                ratio = max_width / img.width
                new_size = (max_width, int(img.height * ratio))
                img = img.resize(new_size, Image.Resampling.LANCZOS)
            
            # 创建输出目录（如果不存在）
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            # 保存优化后的图片
            img.save(output_path, optimize=True, quality=quality)
            
            # 打印优化结果
            original_size = os.path.getsize(input_path) / 1024  # KB
            new_size = os.path.getsize(output_path) / 1024  # KB
            print(f"优化完成: {input_path}")
            print(f"原始大小: {original_size:.1f}KB")
            print(f"优化后大小: {new_size:.1f}KB")
            print(f"压缩率: {(1 - new_size/original_size)*100:.1f}%\n")
            
    except Exception as e:
        print(f"处理图片 {input_path} 时出错: {str(e)}")

def process_directory(input_dir, output_dir):
    """
    处理整个目录的图片
    """
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    
    # 确保输出目录存在
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 处理所有图片文件
    for img_file in input_path.rglob("*"):
        if img_file.suffix.lower() in ['.png', '.jpg', '.jpeg']:
            # 保持相对路径结构
            rel_path = img_file.relative_to(input_path)
            output_file = output_path / rel_path
            
            # 对于 logo 图片使用更大的压缩
            if 'escooter' in img_file.name:
                optimize_image(str(img_file), str(output_file), max_width=800, quality=85)
            # 对于截图使用较小的压缩
            else:
                optimize_image(str(img_file), str(output_file), max_width=1200, quality=90)

if __name__ == "__main__":
    # 设置输入输出目录
    base_dir = Path(__file__).parent.parent.parent
    input_dir = base_dir / "frontend" / "assets" / "images"
    output_dir = base_dir / "frontend" / "assets" / "images_optimized"
    
    print("开始优化图片...")
    process_directory(input_dir, output_dir)
    print("图片优化完成！") 