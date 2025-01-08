use image::{DynamicImage, ImageBuffer};
use rayon::prelude::*;
use std::time::Instant;

/*
Image 1 processing time: 366.332375ms
Image 2 processing time: 369.479ms
Image 3 processing time: 362.557917ms
Total combining time: 3.765370208s
Combined image saving time: 894.583µs
Total execution time: 12.95960025s
 */
fn combine_images_vertical(image_bytes: &[Vec<u8>]) -> Option<Vec<u8>> {
    let start = Instant::now();

    if image_bytes.is_empty() {
        return None;
    }

    // Parallel image loading using rayon
    let images: Vec<DynamicImage> = image_bytes
        .par_iter()
        .filter_map(|bytes| {
            image::load_from_memory(bytes)
                .map_err(|e| {
                    eprintln!("Failed to load image from bytes: {}", e);
                    e
                })
                .ok()
        })
        .collect();

    if images.is_empty() {
        return None;
    }

    let width = images.par_iter().map(|img| img.width()).max().unwrap();
    let total_height: u32 = images.par_iter().map(|img| img.height()).sum();

    let mut combined = ImageBuffer::new(width, total_height);
    let mut current_height = 0;

    // Pre-convert all images to RGBA8 format
    let rgba_images: Vec<_> = images.par_iter().map(|img| img.to_rgba8()).collect();

    for (i, img) in rgba_images.iter().enumerate() {
        let copy_start = Instant::now();

        let rows: Vec<_> = (0..img.height())
            .into_par_iter()
            .map(|y| {
                let mut row = Vec::with_capacity(img.width() as usize);
                for x in 0..img.width() {
                    row.push((x, y + current_height, *img.get_pixel(x, y)));
                }
                row
            })
            .collect();

        for row in rows {
            for (x, y, pixel) in row {
                combined.put_pixel(x, y, pixel);
            }
        }

        current_height += img.height();
        println!(
            "Image {} processing time: {:?}",
            i + 1,
            copy_start.elapsed()
        );
    }

    println!("Total combining time: {:?}", start.elapsed());

    // Convert the combined image to JPEG bytes
    let rgb_image = image::DynamicImage::ImageRgba8(combined).to_rgb8();
    let mut jpeg_bytes = Vec::new();
    match image::codecs::jpeg::JpegEncoder::new(&mut jpeg_bytes).encode_image(&rgb_image) {
        Ok(_) => Some(jpeg_bytes),
        Err(e) => {
            eprintln!("Failed to encode JPEG: {}", e);
            None
        }
    }
}

fn main() {
    let total_start = Instant::now();
    // Load images
    let load_start = Instant::now();
    let image_bytes: Vec<Vec<u8>> = vec![
        std::fs::read("receipt_1.jpeg").unwrap(),
        std::fs::read("receipt_1.1.jpeg").unwrap(),
        std::fs::read("receipt_2.jpeg").unwrap(),
    ];
    println!("Image loading time: {:?}", load_start.elapsed());

    if let Some(combined_bytes) = combine_images_vertical(&image_bytes) {
        let save_start = Instant::now();
        std::fs::write("combined.jpg", combined_bytes).expect("Failed to save image");
        println!("Combined image saving time: {:?}", save_start.elapsed());
    }
    println!("Total execution time: {:?}", total_start.elapsed());
}
