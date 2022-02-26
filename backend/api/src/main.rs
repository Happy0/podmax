use log::{ debug };
use serde::{Deserialize, Serialize};
use lambda_runtime::{handler_fn, Context};
use std::fmt::Formatter;

#[derive(Deserialize)]
struct Request {
    // More fields are available, but this is all I need for now
    pub body: String,
}

#[derive(Debug, Serialize)]
struct SuccessResponse {
    pub body: String,
}

#[derive(Debug, Serialize)]
struct FailureResponse {
    pub body: String,
}

impl std::fmt::Display for FailureResponse {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.body)
    }
}

impl std::error::Error for FailureResponse {}

type Response = Result<SuccessResponse, FailureResponse>;

#[tokio::main]
async fn main() -> Result<(), lambda_runtime::Error> {
    debug!("Daeing hings...");

    let lambdaFn = handler_fn(handler);
    lambda_runtime::run(lambdaFn).await?;

    Ok(())
}

async fn handler(req: Request, _ctx: lambda_runtime::Context) -> Response {

    Ok(SuccessResponse{body: "hi".to_string()})
}