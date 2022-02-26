use log::{ debug };
use lambda_runtime::{handler_fn, Context};
mod model;

#[tokio::main]
async fn main() -> Result<(), lambda_runtime::Error> {
    debug!("Daeing hings...");

    let lambda_fn = handler_fn(handler);

    lambda_runtime::run(lambda_fn).await
}

async fn handler(req: model::Request, _ctx: Context) -> model::Response {

    Ok(model::SuccessResponse{body: "Wit a success!".to_string()})
}