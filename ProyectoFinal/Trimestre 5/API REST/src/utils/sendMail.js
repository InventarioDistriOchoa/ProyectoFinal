import nodemailer from "nodemailer";

export const sendMail = async (to, subject, html) => {
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  try {
    await transporter.verify();
    console.log("✅ SMTP listo para enviar correos");

    const info = await transporter.sendMail({
      from: `"DistriOchoa" <${process.env.EMAIL_USER}>`,
      to,
      subject,
      html,
    });

    console.log("📨 Correo enviado:", info.messageId);
  } catch (err) {
    console.error("❌ Error al enviar correo:", err);
    throw err;
  }
};
