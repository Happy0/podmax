use serde::{Deserialize, Serialize};
use std::fmt::Formatter;

#[derive(Deserialize)]
pub struct Request {
    // More fields are available, but this is all I need for now
    pub body: String,
}

#[derive(Debug, Serialize)]
pub struct SuccessResponse {
    pub body: String
}

pub enum FailureReason {
    BadInput,
    InternalServerError
}

#[derive(Debug, Serialize)]
pub struct FailureResponse {
    pub body: String,
}

impl std::fmt::Display for FailureResponse {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.body)
    }
}

impl std::error::Error for FailureResponse {}

pub type Response = Result<SuccessResponse, FailureResponse>;


