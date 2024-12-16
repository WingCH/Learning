use image::{DynamicImage, ImageBuffer, Rgb, RgbaImage};
use std::time::Instant;

// Vertically combines multiple images into one

/*
result:
Image 1 processing time: 971.287209ms
Image 2 processing time: 961.386875ms
Image 3 processing time: 964.625792ms
Total combining time: 2.8973845s
Combined image saving time: 8.709253875s
Total execution time: 18.05329475s
 */
fn combine_images_vertical(images: &[DynamicImage]) -> Option<RgbaImage> {
    let start = Instant::now();

    // Return None if no images provided
    if images.is_empty() {
        return None;
    }

    // Calculate dimensions of the final image
    let width = images.iter().map(|img| img.width()).max().unwrap();
    let total_height: u32 = images.iter().map(|img| img.height()).sum();

    // Create a new image buffer
    let mut combined = ImageBuffer::new(width, total_height);

    // Keep track of current vertical position
    let mut current_height = 0;

    // Copy each image
    for (i, img) in images.iter().enumerate() {
        let copy_start = Instant::now();
        for (x, y, pixel) in img.to_rgba8().enumerate_pixels() {
            combined.put_pixel(x, y + current_height, *pixel);
        }
        current_height += img.height();
        println!(
            "Image {} processing time: {:?}",
            i + 1,
            copy_start.elapsed()
        );
    }

    println!("Total combining time: {:?}", start.elapsed());
    Some(combined)
}

fn main() {
    let total_start = Instant::now();

    // First create the demo images
    // create_demo_images();

    // Load images
    let load_start = Instant::now();
    let images = vec![
        image::open("receipt_1.jpeg").expect("Failed to open receipt_1"),
        image::open("receipt_1.1.jpeg").expect("Failed to open receipt_1.1"),
        image::open("receipt_2.jpeg").expect("Failed to open receipt_2"),
    ];
    println!("Image loading time: {:?}", load_start.elapsed());

    // Combine images
    if let Some(combined) = combine_images_vertical(&images) {
        let save_start = Instant::now();
        // Convert RGBA to RGB before saving as JPEG
        let rgb_image = image::DynamicImage::ImageRgba8(combined).to_rgb8();
        rgb_image.save("combined.jpg").expect("Failed to save image");
        println!("Combined image saving time: {:?}", save_start.elapsed());
    }

    println!("Total execution time: {:?}", total_start.elapsed());
}
