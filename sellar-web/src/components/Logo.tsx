import Link from "next/link";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  href?: string;
}

const sizes = {
  sm: { icon: "w-7 h-7 text-xs", text: "text-lg" },
  md: { icon: "w-8 h-8 text-sm", text: "text-xl" },
  lg: { icon: "w-10 h-10 text-base", text: "text-2xl" },
};

export default function Logo({ size = "md", href = "/" }: LogoProps) {
  const s = sizes[size];
  return (
    <Link href={href} className="flex items-center gap-2 shrink-0">
      <div
        className={`${s.icon} bg-linear-to-br from-indigo-500 to-violet-500 rounded-lg flex items-center justify-center`}
      >
        <span className="text-white font-bold">S</span>
      </div>
      <span className={`${s.text} font-bold text-slate-900`}>Sellar</span>
    </Link>
  );
}
