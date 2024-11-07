#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world! from optimized image"
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}
