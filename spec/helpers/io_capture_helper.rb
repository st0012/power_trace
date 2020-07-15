module IOCaptureHelper
  def capture_io(&block)
    original_stdout = $stdout
    original_stderr = $stderr

    captured_stdout = StringIO.new
    captured_stderr = StringIO.new

    $stdout = captured_stdout
    $stderr = captured_stderr

    yield

    {
      stdout: captured_stdout.string,
      stderr: captured_stderr.string
    }
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  def silent_io
    original_stdout = $stdout
    original_stderr = $stderr

    $stdout = $stderr = StringIO.new

    yield
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end
end
