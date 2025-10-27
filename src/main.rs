use anyhow::{Context, Result, anyhow};
use clap::{Parser, Subcommand};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::{Path, PathBuf};

#[derive(Serialize, Deserialize, Debug)]
pub struct Config {
    pub progs: HashMap<String, String>,
}

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    cmd: Commands,
    #[arg(short = 'c', long = "config")]
    config: Option<PathBuf>,
}
#[derive(Subcommand, Debug)]
enum Commands {
    Gen {},
    Lut {},
}

fn get_config_path() -> Result<std::path::PathBuf> {
    // First, check for user-specific config (~/.config/myapp/config.yaml)
    if let Some(c) = dirs::config_dir()
        .map(|x| x.join("dmenu-launcher.yml"))
        .filter(|x| x.exists())
    {
        return Ok(c);
    }
    // If user-specific config does not exist, fallback to system-wide config (/usr/local/etc/myapp/config.yaml)
    let system_config_path =
        Path::new(option_env!("PREFIX").unwrap_or("/usr/local")).join("etc/dmenu-launcher.yml");

    if system_config_path.exists() {
        return Ok(system_config_path.to_path_buf());
    }

    Err(anyhow!(
        "No config file found (system-level expected at {:?})",
        system_config_path
    ))
}

fn load_config(c: PathBuf) -> Result<Config> {
    let content: Config = serde_yaml::from_reader(
        File::open(c.clone()).with_context(|| format!("Failed opening '{:?}'", c))?,
    )?;
    Ok(content)
}

fn main() -> Result<()> {
    let args = Cli::parse();
    // println!("args {:?}", args);
    let cfg = load_config(args.config.map_or_else(get_config_path, Ok)?)?;
    // println!("{:?}", cfg);
    match args.cmd {
        Commands::Gen {} => {
            for i in cfg.progs.keys() {
                println!("{}", i)
            }
        }
        Commands::Lut {} => {
            let stdin = io::stdin();
            let mut line = String::new();
            stdin.lock().read_line(&mut line)?;
            let line = line.trim_end();
            let cmd = cfg
                .progs
                .get(line)
                .with_context(|| format!("'{}' not a valid input, no command defined", line))?;
            println!("{}", cmd);
        }
    }
    Ok(())
}
