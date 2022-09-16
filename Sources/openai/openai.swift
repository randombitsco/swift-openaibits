import ArgumentParser
import Foundation
import OpenAIBits

struct AppError: Error, CustomStringConvertible {
  let description: String
  
  init(_ description: String) {
    self.description = description
  }
}

func readSTDIN () -> String? {
    var input: String?

    while let line = readLine() {
        if input == nil {
            input = line
        } else {
            input! += "\n" + line
        }
    }

    return input
}

@main
struct openai: AsyncParsableCommand {
  
  static var configuration = CommandConfiguration(
    commandName: "openai",
    abstract: "A utility for accessing OpenAI APIs.",
    version: "0.2.0",
    
    subcommands: [
      ModelsCommand.self,
      CompletionsCommand.self,
      EditsCommand.self,
      EmbeddingsCommand.self,
      FilesCommand.self,
      FineTunesCommand.self,
      ModerationsCommand.self,
      TokensCommand.self,
    ]
  )
}

struct Config: ParsableArguments {
  @Option(help: "The OpenAI API Key. If not provided, uses the 'OPENAI_API_KEY' environment variable.")
  var apiKey: String?
  
  @Option(help: "The OpenAI Organisation key. If not provided, uses the 'OPENAI_ORG_KEY' environment variable.")
  var orgKey: String?
  
  @Flag(help: "Output more details.")
  var verbose: Bool = false
  
  @Flag(help: "Output debugging information.")
  var debug: Bool = false
  
  func findApiKey() -> String? {
    apiKey ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
  }
  
  func findOrgKey() -> String? {
    orgKey ?? ProcessInfo.processInfo.environment["OPENAI_ORG_KEY"]
  }
  
  var log: Client.Logger? {
    guard debug else {
      return nil
    }
    return { print($0) }
  }
  
  func client() -> Client {
    Client(apiKey: findApiKey() ?? "NO API KEY PROVIDED", organization: findOrgKey(), log: log)
  }
  
  /// The default format, given the config.
  func format() -> Format {
    verbose ? .verbose() : .default
  }
  
  mutating func validate() throws {
    guard findApiKey() != nil else {
      throw ValidationError("Please provide an OpenAI API Key either via --api-key or the 'OPENAI_API_KEY' environment variable.")
    }
  }
}

extension Percentage: ExpressibleByArgument {
  public init?(argument: String) {
    guard let value = Double.init(argument: argument) else {
      return nil
    }
    self.init(value)
  }
}

extension Penalty: ExpressibleByArgument {
  public init?(argument: String) {
    guard let value = Double.init(argument: argument) else {
      return nil
    }
    self.init(value)
  }
}
