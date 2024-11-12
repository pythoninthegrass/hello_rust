#[macro_use]
extern crate rocket;
use rocket::fs::FileServer;
use rocket::response::content;
use std::path::Path;

fn get_static_path() -> &'static str {
    if Path::new("/app/static").exists() {
        "static"
    } else {
        "src/static"
    }
}

#[get("/")]
async fn index() -> content::RawHtml<Option<String>> {
    let static_path = get_static_path();
    content::RawHtml(std::fs::read_to_string(format!("{}/index.html", static_path)).ok())
}

#[launch]
fn rocket() -> _ {
    dotenvy::dotenv().ok();

    let port: u16 = std::env::var("ROCKET_PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse()
        .unwrap_or(8080);

    let static_path = get_static_path();

    rocket::build()
        .mount("/", routes![index])
        .mount("/assets", FileServer::from(static_path))
        .configure(rocket::Config {
            port,
            address: "0.0.0.0".parse().unwrap(),
            ..rocket::Config::default()
        })
}
