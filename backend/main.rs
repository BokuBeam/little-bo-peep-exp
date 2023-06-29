use axum::{
    http::StatusCode,
    routing::{get, get_service},
    Json, Router,
};
use std::{collections::HashMap, fs, io};
use std::{io::Read, net::SocketAddr};
use tower::ServiceBuilder;
use tower_http::{
    cors::{self, CorsLayer},
    services::{ServeDir, ServeFile},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "little-bo-peep-exp=debug".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let app = Router::new()
        .route("/api/articles", get(get_articles))
        .nest_service(
            "/assets",
            get_service(ServeDir::new("dist/assets")).handle_error(
                |error: std::io::Error| async move {
                    (
                        StatusCode::INTERNAL_SERVER_ERROR,
                        format!("Unhandled internal error: {}", error),
                    )
                },
            ),
        )
        .fallback_service(get_service(ServeFile::new("dist/index.html")).handle_error(
            |_| async move { (StatusCode::INTERNAL_SERVER_ERROR, "internal server error") },
        ))
        .layer(
            CorsLayer::new()
                .allow_origin(cors::Any)
                .allow_methods(cors::Any)
                .allow_headers(cors::Any)
                .expose_headers(cors::Any),
        )
        .layer(ServiceBuilder::new().layer(TraceLayer::new_for_http()));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::debug!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn get_articles() -> Result<Json<HashMap<String, String>>, StatusCode> {
    fs::read_dir("dist/assets/articles/")
        .map(|read_dir| read_dir.map(|entry| entry_to_file(entry.unwrap())))
        .unwrap()
        .collect::<Result<HashMap<_, _>, StatusCode>>()
        .map(|res| Json(res))
}

fn entry_to_file(entry: fs::DirEntry) -> Result<(String, String), StatusCode> {
    let name: String = entry
        .file_name()
        .into_string()
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .split('.')
        .next()
        .map(|s| s.to_owned())
        .ok_or(StatusCode::INTERNAL_SERVER_ERROR)?;

    entry
        .path()
        .into_os_string()
        .into_string()
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
        .and_then(|entry_string| open_file(entry_string))
        .map(|contents| (name, contents))
}

fn open_file(path: String) -> Result<String, StatusCode> {
    let file = fs::File::open(path).map_err(|_| StatusCode::BAD_REQUEST)?;
    let mut buf_reader = io::BufReader::new(file);
    let mut contents = String::new();
    buf_reader
        .read_to_string(&mut contents)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(contents)
}
