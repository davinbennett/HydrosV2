package utils

import (
	"bytes"
	"crypto/rand"
	"fmt"
	"net/smtp"
	"os"
)

func GenerateOTP() (string, error){
	const charset = "0123456789"
	const length = 6 // 6 digit OTP

	otpByte := make([]byte, length)
	_, err := rand.Read(otpByte)
	if err != nil {
		return "", err
	}

	for i := range length{
		otpByte[i] = charset[otpByte[i]%byte(len(charset))]
	}

	return string(otpByte), nil
}

func SendOTPEmail(to, otp string) error {
	from := os.Getenv("SMTP_EMAIL")
	pass := os.Getenv("SMTP_PASSWORD")
	host := os.Getenv("SMTP_HOST")
	port := os.Getenv("SMTP_PORT")

	subject := "Hydros Security: Your OTP"
	body := fmt.Sprintf(`
	<html>
	<body>
		<h2 style="color:#2CC49C;">Hydros Account Verification</h2>
		<p>Your OTP code is: <strong style="font-size:18px;">%s</strong></p>
		<p style="color:#6b7280;">
			This code will expire in 5 minutes.<br>
			<b>Do not share</b> this code with anyone, including Hydros support.
		</p>
		<hr style="border:1px solid #e5e7eb;">
		<p style="font-size:12px;color:#9ca3af;">
			If you didn't request this code, please secure your account immediately.
		</p>
	</body>
	</html>
	`, otp)

	// MIME headers for HTML email
	headers := make(map[string]string)
	headers["From"] = from
	headers["To"] = to
	headers["Subject"] = subject
	headers["MIME-Version"] = "1.0"
	headers["Content-Type"] = "text/html; charset=UTF-8"

	var msg bytes.Buffer
	for k, v := range headers {
		msg.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	msg.WriteString("\r\n" + body)

	auth := smtp.PlainAuth("", from, pass, host)
	addr := fmt.Sprintf("%s:%s", host, port)
	
	err := smtp.SendMail(addr, auth, from, []string{to}, msg.Bytes())
	if err != nil {
		return fmt.Errorf("failed to send OTP email: %w", err)
	}
	return nil
}

