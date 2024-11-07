#[macro_use] extern crate rocket;
use rocket::fs::FileServer;
use rocket::response::content;

#[get("/")]
async fn index() -> content::RawHtml<Option<String>> {
    content::RawHtml(std::fs::read_to_string("src/static/index.html").ok())
}

#[launch]
fn rocket() -> _ {
    dotenvy::dotenv().ok();

    let port: u16 = std::env::var("ROCKET_PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse()
        .unwrap_or(8080);

    rocket::build()
        .mount("/", routes![index])
        .mount("/assets", FileServer::from("src/static"))
        .configure(rocket::Config {
            port,
            address: "0.0.0.0".parse().unwrap(),
            ..rocket::Config::default()
        })
}
