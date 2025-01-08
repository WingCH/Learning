use image::{DynamicImage, ImageBuffer, Rgba};
use rayon::prelude::*;
use std::time::Instant;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

pub fn combine_images_vertical(image_bytes: &[Vec<u8>]) -> Option<Vec<u8>> {
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

pub fn merge_images_vertically(image_buffers: &[Vec<u8>]) -> Option<Vec<u8>> {
    let start_time = Instant::now();

    // 1. Quick check for empty input
    if image_buffers.is_empty() {
        return None;
    }

    // 2. Load images in parallel using rayon, filter out invalid data
    let images: Vec<DynamicImage> = image_buffers
        .par_iter()
        .filter_map(|bytes| {
            image::load_from_memory(bytes)
                .map_err(|err| {
                    eprintln!("Failed to load image from bytes: {}", err);
                    err
                })
                .ok()
        })
        .collect();

    // If no valid images could be loaded, return None
    if images.is_empty() {
        return None;
    }

    // 3. Calculate the final merged dimensions:
    //    - The final width is the max width of all images
    //    - The total height is the sum of all images' heights
    let final_width = images.par_iter().map(|img| img.width()).max().unwrap();
    let total_height: u32 = images.par_iter().map(|img| img.height()).sum();

    // 4. Allocate an ImageBuffer to store the merged image
    let mut merged_buffer = ImageBuffer::from_pixel(
        final_width,
        total_height,
        Rgba([255, 255, 255, 255]), // White color
    );
    // 5. Convert all images to RGBA8 in parallel
    let rgba_images: Vec<_> = images.par_iter().map(|img| img.to_rgba8()).collect();

    // Keep track of the current y-offset while placing images vertically
    let mut current_offset_y = 0;

    // 6. Merge each image vertically
    for (idx, rgba_img) in rgba_images.iter().enumerate() {
        let single_image_start = Instant::now();

        // Copy pixels from each RGBA image into the merged_buffer
        for y in 0..rgba_img.height() {
            for x in 0..rgba_img.width() {
                let pixel: &Rgba<u8> = rgba_img.get_pixel(x, y);
                merged_buffer.put_pixel(x, y + current_offset_y, *pixel);
            }
        }
        current_offset_y += rgba_img.height();

        // Print timing for each image
        println!(
            "Image {} processing time: {:?}",
            idx + 1,
            single_image_start.elapsed()
        );
    }

    println!("Total merging time: {:?}", start_time.elapsed());

    // 7. Encode the merged image as JPEG
    let rgb_image = DynamicImage::ImageRgba8(merged_buffer).to_rgb8();
    let mut jpeg_bytes = Vec::new();
    match image::codecs::jpeg::JpegEncoder::new(&mut jpeg_bytes).encode_image(&rgb_image) {
        Ok(_) => Some(jpeg_bytes),
        Err(err) => {
            eprintln!("Failed to encode JPEG: {}", err);
            None
        }
    }
}
