use axum::{http::StatusCode, routing::get_service, Router};
use std::net::SocketAddr;
use tower::ServiceBuilder;
use tower_http::{
    cors::{self, CorsLayer},
    services::{ServeDir, ServeFile},
    trace::TraceLayer,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
    let service = ServeDir::new("dist/assets").fallback(ServeFile::new("dist/index.html"));

    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "little-bo-peep-exp=debug".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let app = Router::new()
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
