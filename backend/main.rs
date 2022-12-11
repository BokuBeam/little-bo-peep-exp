use axum::Router;
use axum_extra::routing::SpaRouter;
use std::net::SocketAddr;
use tower::ServiceBuilder;
use tower_http::{
    cors::{self, CorsLayer},
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

    let spa = SpaRouter::new("/", "dist");

    // build our application with some routes
    let app = Router::new()
        .merge(spa)
        .layer(
            CorsLayer::new()
                .allow_origin(cors::Any)
                .allow_methods(cors::Any)
                .allow_headers(cors::Any)
                .expose_headers(cors::Any),
        )
        .layer(ServiceBuilder::new().layer(TraceLayer::new_for_http()));

    // run it
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::debug!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
